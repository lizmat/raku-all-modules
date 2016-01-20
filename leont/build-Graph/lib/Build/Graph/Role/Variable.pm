package Build::Graph::Role::Variable;

use strict;
use warnings;

use Carp ();
use Scalar::Util ();

sub new {
	my ($class, %args) = @_;
	my $self = bless {
		graph   => $args{graph},
		name    => $args{name}    || Carp::croak('No name given'),
		entries => $args{entries} || [],
		substs  => $args{substs}  || [],
	}, $class;
	Scalar::Util::weaken($self->{graph});
	return $self;
}

sub entries {
	my $self = shift;
	return @{ $self->{entries} };
}

sub on_file {
	my ($self, $sub) = @_;
	push @{ $self->{substs} }, $sub;
	for my $file (@{ $self->{entries} }) {
		$sub->process($file);
	}
	return;
}

sub trigger {
	my ($self, @entries) = @_;
	for my $entry (@entries) {
		for my $subst (@{ $self->{substs} }) {
			$subst->process($entry);
		}
	}
	return;
}

sub to_hashref {
	my $self = shift;
	my %ret;
	$ret{type}    = lc +(ref($self) =~ /^Build::Graph::Variable::(\w+)$/)[0];
	$ret{entries} = $self->{entries} if @{ $self->{entries} };
	$ret{substs}  = [ map { $_->{name} } @{ $self->{substs} } ] if @{ $self->{substs} };
	return \%ret;
}

1;

# ABSTRACT: A role shared by sets of entries (e.g. wildcards and substitutions)
