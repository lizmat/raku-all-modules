package Build::Graph::Variable::Subst;

use strict;
use warnings;

use parent 'Build::Graph::Role::Variable';

use Carp ();

sub new {
	my ($class, %args) = @_;
	my $self = $class->SUPER::new(%args);
	$self->{subst}        = $args{subst}        || Carp::croak('No subst given');
	$self->{action}       = $args{action}       || Carp::croak('No action given');
	$self->{dependencies} = $args{dependencies} || [];
	return $self;
}

sub process {
	my ($self, $source) = @_;

	my @command = $self->{graph}->expand({ source => $source }, @{ $self->{subst} });
	my $target = $self->{graph}->run_subst(@command);

	$self->{graph}->add_file($target, dependencies => [ $source, @{ $self->{dependencies} } ], action => $self->{action});
	push @{ $self->{entries} }, $target;
	$self->trigger($target);
	return;
}

sub to_hashref {
	my $self = shift;
	my $ret  = $self->SUPER::to_hashref;
	@{$ret}{qw/subst action/} = @{$self}{qw/subst action/};
	$ret->{dependencies} = $self->{dependencies} if @{ $self->{dependencies} };
	return $ret;
}

1;

#ABSTRACT: Substitutions on filenames in a Build::Graph graph
