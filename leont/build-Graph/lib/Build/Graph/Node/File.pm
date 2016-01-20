package Build::Graph::Node::File;

use strict;
use warnings;

use parent 'Build::Graph::Role::Node';

sub run {
	my ($self, $options) = @_;
	my $filename = $self->name;

	my $graph = $self->{graph};
	my @files = grep { $graph->get_node($_) && $graph->get_node($_)->isa(__PACKAGE__) || -e } $graph->expand({}, $self->dependencies);

	return if -e $filename and sub { -d or -M $filename <= -M or return 0 for @files; 1 }->();

	$self->SUPER::run($options);

	return;
}

1;

#ABSTRACT: A dependency graph node for file targets

=method make_dir

