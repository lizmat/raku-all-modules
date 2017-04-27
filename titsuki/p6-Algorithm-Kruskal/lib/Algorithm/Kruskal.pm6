use v6;
unit class Algorithm::Kruskal;

use Algorithm::MinMaxHeap;
use Algorithm::SetUnion;
use Algorithm::MinMaxHeap::Comparable;

has $.vertex-size is required;
has Algorithm::MinMaxHeap $!heap;

submethod BUILD(:$!vertex-size) {
    $!heap = Algorithm::MinMaxHeap[Algorithm::MinMaxHeap::Comparable].new;
}

method add-edge(Int $from, Int $to, Real $weight) {
    my class State {
	also does Algorithm::MinMaxHeap::Comparable[State];
	
	has ($.from, $.to);
	has $.weight;
	submethod BUILD (:$!from, :$!to, :$!weight) {}
	method compare-to(State $s) {
	    if (self.weight == $s.weight) {
		return Order::Same;
	    }
	    if (self.weight > $s.weight) {
		return Order::More;
	    }
	    if (self.weight < $s.weight) {
		return Order::Less;
	    }
	}
    }
    $!heap.insert(State.new(from => $from, to => $to, weight => $weight));
}

method compute-minimal-spanning-tree() returns List {
    my $weight = 0;
    my @edges;
    my $prev-heap = $!heap.clone;
    my Algorithm::SetUnion $set-union = Algorithm::SetUnion.new(size => $!vertex-size);
    while (not $!heap.is-empty()) {
	my $state = $!heap.pop-min;
	if ($set-union.union($state.from, $state.to)) {
	    $weight += $state.weight;
	    @edges.push([$state.from, $state.to]);
	}
    }
    $!heap = $prev-heap;
    return :@edges, :$weight;
}

=begin pod

=head1 NAME

Algorithm::Kruskal -  a perl6 implementation of Kruskal's Algorithm for constructing a spanning subtree of minimum length

=head1 SYNOPSIS

  use Algorithm::Kruskal;

  my $kruskal = Algorithm::Kruskal.new(vertex-size => 4);
  
  $kruskal.add-edge(0, 1, 2);
  $kruskal.add-edge(1, 2, 1);
  $kruskal.add-edge(2, 3, 1);
  $kruskal.add-edge(3, 0, 1);
  $kruskal.add-edge(0, 2, 3);
  $kruskal.add-edge(1, 3, 5);
  
  my %forest = $kruskal.compute-minimal-spanning-tree();
  %forest<weight>.say; # 3
  %forest<edges>.say; # [[1 2] [2 3] [3 0]]

=head1 DESCRIPTION

Algorithm::Kruskal is a perl6 implementation of Kruskal's Algorithm for constructing a spanning subtree of minimum length

=head2 CONSTRUCTOR

       my $kruskal = Algorithm::Kruskal.new(%options);

=head3 OPTIONS

=item C<<vertex-size => $vertex-size>>

Sets vertex size. The vertices are numbered from C<<0>> to C<<$vertex-size - 1>>.

=head2 METHODS

=head3 add-edge(Int $from, Int $to, Real $weight)

       $kruskal.add-edge($from, $to, $weight);

Adds a edge to the graph. C<<$weight>> is the weight between vertex C<<$from>> and vertex C<<$to>>.

=head3 compute-minimal-spanning-tree() returns List

       my %forest = $kruskal.compute-minimal-spanning-tree();
       %forest<edges>.say; # display edges
       %forest<weight>.say; # display weight

Computes and returns a minimal spanning tree and its weight.

=head1 AUTHOR

titsuki <titsuki@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2016 titsuki

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

This algorithm is from Kruskal, Joseph B. "On the shortest spanning subtree of a graph and the traveling salesman problem." Proceedings of the American Mathematical society 7.1 (1956): 48-50.

=end pod
