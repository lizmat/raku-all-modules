package Build::Graph;

use strict;
use warnings;

use Carp qw//;

use Build::Graph::Node::File;
use Build::Graph::Node::Phony;

use Build::Graph::Variable::Wildcard;
use Build::Graph::Variable::Subst;
use Build::Graph::Variable::Free;

sub new {
	my ($class, %args) = @_;
	return bless {
		nodes     => $args{nodes}     || {},
		plugins   => $args{plugins}   || {},
		variables => $args{variables} || {},
		counter   => $args{counter}   || 1,
	}, $class;
}

sub _expand {
	my ($self, $options, $key, $count) = @_;
	Carp::croak("Deep variable recursion detected involving $key") if $count > 20;
	if ($key =~ / \A \@\( ([\w.-]+) \) \z /xm) {
		my $variable = $self->{variables}{$1} or Carp::croak("No such variable $1");
		return map { $self->_expand($options, $_, $count + 1) } $variable->entries;
	}
	elsif ($key =~ / \A %\( ([\w.,-]+) \) \z /xm) {
		my @keys = grep { exists $options->{$_} } split /,/, $1;
		return { map { $_ => $options->{$_} } @keys };
	}
	$key =~ s/ \$\( ([\w.-]+) \) / $self->_expand($options, $options->{$1} || Carp::croak("No such argument $1"), $count + 1) /gex;

	return $key;
}

sub expand {
	my ($self, $options, @values) = @_;
	return map { $self->_expand($options, $_, 1) } @values;
}

sub run_command {
	my ($self, $command, @args) = @_;
	my ($groupname, $subcommand) = split m{/}, $command, 2;
	my $group = $self->{plugins}{$groupname};
	my $callback = $group ? $group->lookup_command($subcommand, $self) : Carp::croak("No such command $command");
	return $callback->(@args);
}

sub run_subst {
	my ($self, $command, @args) = @_;
	my ($groupname, $subst) = split m{/}, $command, 2;
	my $group = $self->{plugins}{$groupname};
	my $subst_action = $group ? $group->lookup_subst($subst) : Carp::croak("No such subst $command");
	return $subst_action->(@args);
}

sub get_node {
	my ($self, $key) = @_;
	return $self->{nodes}{$key};
}

sub add_file {
	my ($self, $name, %args) = @_;
	my $ret = $self->_add_node($name, %args, type => 'File');
	$self->match($name);
	return $ret;
}

sub add_phony {
	my ($self, $name, %args) = @_;
	return $self->_add_node($name, %args, type => 'Phony');
}

sub _add_node {
	my ($self, $name, %args) = @_;
	my $type = delete $args{type};
	Carp::croak("$type '$name' already exists in database") if !$args{override} && exists $self->{nodes}{$name};
	$self->{nodes}{$name} = "Build::Graph::Node::$type"->new(%args, name => $name, graph => $self);;
	$self->add_variable($args{add_to}, $name) if $args{add_to};
	return $name;
}

sub add_wildcard {
	my ($self, $name, %args) = @_;
	if (ref($args{pattern}) ne 'Regexp') {
		require Text::Glob;
		$args{pattern} = Text::Glob::glob_to_regex($args{pattern});
	}
	my $wildcard = Build::Graph::Variable::Wildcard->new(%args, graph => $self, name => $name);
	$self->{variables}{$name} = $wildcard;
	$wildcard->match($_) for grep { $self->{nodes}{$_}->isa('Build::Graph::Node::File') } keys %{ $self->{nodes} };
	return;
}

sub add_variable {
	my ($self, $name, @values) = @_;
	$self->{variables}{$name} ||= Build::Graph::Variable::Free->new(name => $name);
	$self->{variables}{$name}->add_entries(@values);
	return;
}

sub match {
	my ($self, @names) = @_;
	my @wildcards = grep { $_->isa('Build::Graph::Variable::Wildcard') } values %{ $self->{variables} };
	for my $name (@names) {
		for my $wildcard (@wildcards) {
			$wildcard->match($name);
		}
	}
	return;
}

sub add_subst {
	my ($self, $name, $sourcename, %args) = @_;
	my $source = $self->{variables}{$sourcename};
	my $sub = Build::Graph::Variable::Subst->new(%args, graph => $self, name => $name);
	$source->on_file($sub);
	$self->{variables}{$name} = $sub;
	return;
}

my $node_sorter;
$node_sorter = sub {
	my ($self, $current, $callback, $seen, $loop) = @_;
	Carp::croak("$current has a circular dependency, aborting!\n") if exists $loop->{$current};
	return if $seen->{$current}++;
	local $loop->{$current} = 1;
	if (my $node = $self->get_node($current)) {
		$self->$node_sorter($_, $callback, $seen, $loop) for $self->expand({}, $node->dependencies);
		$callback->($current, $node);
	}
	elsif (not -e $current) {
		Carp::croak("Node $current doesn't exist");
	}
	return;
};

sub run {
	my ($self, $startpoint, %options) = @_;
	$self->$node_sorter($startpoint, sub { $_[1]->run(\%options) }, {}, {});
	return;
}

sub _sort_nodes {
	my ($self, $startpoint) = @_;
	my @ret;
	$self->$node_sorter($startpoint, sub { push @ret, $_[0] }, {}, {});
	return @ret;
}

sub to_hashref {
	my $self      = shift;
	my %nodes     = map { $_ => $self->get_node($_)->to_hashref } keys %{ $self->{nodes} };
	my %variables = map { $_ => $self->{variables}{$_}->to_hashref } keys %{ $self->{variables} };
	my @plugins = map { $_->to_hashref } sort { $a->{counter} <=> $b->{counter} } values %{ $self->{plugins} };
	return {
		plugins   => \@plugins,
		nodes     => \%nodes,
		variables => \%variables,
	};
}

sub _load_variables {
	my ($self, $source, $name) = @_;
	my $entry = $source->{$name};
	_load_variables($self, $source, $_) for grep { not $self->{variables}{$_} } @{ $entry->{substs} };
	my @substs  = map { $self->{variables}{$_} } @{ $entry->{substs} };
	my $class   = "Build::Graph::Variable::\u$entry->{type}";
	my $entries = $class->new(%{$entry}, substs => \@substs, graph => $self, name => $name);
	$self->{variables}{$name} = $entries;
	return;
}

sub load {
	my ($class, $hashref, $callback) = @_;
	my $self = Build::Graph->new;
	for my $name (keys %{ $hashref->{variables} }) {
		next if $self->{variables}{$name};
		_load_variables($self, $hashref->{variables}, $name);
	}
	for my $key (keys %{ $hashref->{nodes} }) {
		my $value = $hashref->{nodes}{$key};
		my $class = "Build::Graph::Node::\u$value->{type}";
		$self->{nodes}{$key} = $class->new(%{$value}, name => $key, graph => $self);
	}
	for my $plugin (@{ $hashref->{plugins} }) {
		my $plugin = $self->load_plugin($plugin->{module}, %{$plugin});
		$callback->($plugin) if $callback;
	}
	return $self;
}

sub load_plugin {
	my ($self, $module, %args) = @_;
	(my $filename = "$module.pm") =~ s{::}{/}g;
	require $filename;
	my $plugin = $module->new(%args, graph => $self, counter => $self->{counter}++);
	my $name = $plugin->name;
	Carp::croak("Plugin collision: $name already exists") if exists $self->{plugins}{$name};
	$self->{plugins}{$name} = $plugin;
	return $plugin;
}

1;

# ABSTRACT: A simple dependency graph

=method get_node

=method add_file

=method add_phony

=method all_actions

=method get_action

=method add_action

=method run

=method nodes_to_hashref

=method load_from_hashref
