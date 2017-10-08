use v6;
unit class Algorithm::SetUnion;

use Algorithm::SetUnion::Node;

has $.size;
has Algorithm::SetUnion::Node @.nodes;

submethod BUILD(:$!size) {
    loop (my $i = 0; $i < $!size; $i++) {
	@!nodes.push(Algorithm::SetUnion::Node.new(parent => $i, size => 1));
    }
}

method union(Int $left-index, Int $right-index) returns Bool:D {
    my $left-root = self.find($left-index);
    my $right-root = self.find($right-index);
    return False if ($left-root == $right-root);
    
    if (@!nodes[$left-root].size < @!nodes[$right-root].size) {
	@!nodes[$left-root].parent = $right-root;
	@!nodes[$right-root].size = @!nodes[$left-root].size + @!nodes[$right-root].size;
    } else {
	@!nodes[$right-root].parent = $left-root;
	@!nodes[$left-root].size = @!nodes[$left-root].size + @!nodes[$right-root].size;
    }
    return True;
}

method find(Int $index) returns Int:D {
    my $root = $index;
    my $current = $index;
    while (@!nodes[$root].parent != $root) {
	$root = @!nodes[$root].parent;
    }
    while (@!nodes[$current].parent != $current) {
	my $save = @!nodes[$current].parent;
	@!nodes[$current].parent = $root;
	$current = $save;
    }
    return $root;
}

=begin pod

=head1 NAME

Algorithm::SetUnion - a perl6 implementation for solving the disjoint set union problem (a.k.a. Union-Find Tree)

=head1 SYNOPSIS

  use Algorithm::SetUnion;

  my $set-union = Algorithm::SetUnion.new(size => 5);
  $set-union.union(0,1);
  $set-union.union(1,2);

  my $root = $set-union.find(0);

=head1 DESCRIPTION

Algorithm::SetUnion is a perl6 implementation for solving the disjoint set union problem (a.k.a. Union-Find Tree).

=head2 CONSTRUCTOR

       my $set-union = Algorithm::SetUnion.new(%options);

=head3 OPTIONS

=item C<<size => $size>>

Sets the number of disjoint sets.

=head2 METHODS

=head3 find(Int $index) returns Int:D

       my $root = $set-union.find($index);

Returns the name(i.e. root) of the set containing element C<<$index>>.

=head3 union(Int $left-index, Int $right-index) returns Bool:D

       $set-union.union($left-index, $right-index);

Unites sets containing element C<<$left-index>> and C<<$right-index>>. If sets are equal, it returns False otherwise True.

=head1 AUTHOR

titsuki <titsuki@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2016 titsuki

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

This algorithm is from Tarjan, Robert Endre. "A class of algorithms which require nonlinear time to maintain disjoint sets." Journal of computer and system sciences 18.2 (1979): 110-127.

=end pod
