use v6;
unit class Algorithm::KdTree is export is repr('CStruct');

use NativeCall;
use NativeHelpers::Array;
use Algorithm::KdTree::Response;

my constant $library = %?RESOURCES<libraries/kdtree>.Str;

my sub kd_insert(Algorithm::KdTree, CArray[num64], Pointer) returns int32 is native($library) { * }
my sub kd_nearest(Algorithm::KdTree, CArray[num64]) returns Algorithm::KdTree::Response is native($library) { * }
my sub kd_nearest_range(Algorithm::KdTree, CArray[num64], num64) returns Algorithm::KdTree::Response is native($library) { * }
my sub kd_create(int32) returns Algorithm::KdTree is native($library) { * }
my sub kd_free(Algorithm::KdTree) is native($library) { * }
my sub kd_clear(Algorithm::KdTree) is native($library) { * }
my int32 $c-dimension;

method insert(@array) returns Int {
    if (@array.elems != $c-dimension) {
	die "Error: The dimension of the input is different from kd-tree's one.";
    }
    my Pointer $null;
    my $carray = copy-to-carray(@array, num64);
    return kd_insert(self, $carray, $null);
}

method nearest(@array) returns Algorithm::KdTree::Response {
    my $carray = copy-to-carray(@array, num64);
    return kd_nearest(self, $carray).set-dimension(@array.elems);
}

method nearest-range(@array, Num:D $range) returns Algorithm::KdTree::Response {
    my $carray = copy-to-carray(@array, num64);
    return kd_nearest_range(self, $carray, $range).set-dimension(@array.elems);
}

method new(Int:D $p6-dimension) {
    $c-dimension = $p6-dimension;
    return kd_create($c-dimension);
}

submethod DESTROY {
    kd_free(self);
}

=begin pod

=head1 NAME

Algorithm::KdTree - a perl6 binding for C implementation of the Kd-Tree Algorithm (https://github.com/jtsiomb/kdtree)

=head1 SYNOPSIS

  use Algorithm::KdTree;

  my $kdtree = Algorithm::KdTree.new(3);
  
  $kdtree.insert([0e0,0e0,0e0]);
  $kdtree.insert([10e0,10e0,10e0]);
  
  my $nearest-response = $kdtree.nearest([1e0,1e0,1e0]);
  if (not $nearest-response.is-end()) {
     $nearest-response.get-position().say; # [0e0, 0e0, 0e0]
  }

  my $range-response = $kdtree.nearest-range([9e0,9e0,9e0], sqrt(5));
  my @array;
  while (not $range-response.is-end()) {
     @array.push($range-response.get-position());
     $range-response.next();
  }
  @array.perl.say; # [[10e0, 10e0, 10e0], ]

=head1 DESCRIPTION

Algorithm::KdTree is a perl6 binding for C implementation of the Kd-Tree Algorithm (https://github.com/jtsiomb/kdtree). Kd-Tree is the efficient algorithm for searching nearest neighbors in the k-dimensional space.

=head2 CONSTRUCTOR

=head3 new(Int $dimension)

       my $kdtree = Algorithm::KdTree.new(3);
       my $kdtree = Algorithm::KdTree.new(256); # it could handle a huge dimensional space

Sets dimension C<<$dimension>> for constructing C<<$dimension>>-dimensional Kd-Tree.

=head2 METHODS

=head3 insert(@array)

       $kdtree.insert([1e0, 2e0, 3e0]);

Inserts a k-dimensional array.

=head3 nearest(@array)

       my $response = $kdtree.nearest([1e0, 2e0, 3e0]);
       if (not $response.is-end()) {
       	  my $position = $response.get-position();

	  # YOUR CODE IS HERE
	  # ...
       }

Returns a response which includes the nearest neighbor position of the query C<<@array>> in the Kd-Tree.
If the Kd-Tree has no elements, it returns a response which does not include any positions.

=head3 nearest-range(@array, Num $radius)

       my $response = $kdtree.nearest-range([1e0, 2e0, 3e0], 10e0);
       while (not $response.is-end()) {
       	  my $position = $response.get-position();
	  
	  # YOUR CODE IS HERE
	  # ...
	  
	  $response.next();
       }

Returns a response which includes positions in the hypersphere. The center of this hypersphere is C<<@array>> and the radius of this is C<<$radius>>.
If the Kd-Tree has no elements or no elements are found in the hypersphere, it returns a response which does not include any positions.

=head1 AUTHOR

titsuki <titsuki@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2016 titsuki

Copyright 2007-2011 John Tsiombikas <nuclear@member.fsf.org>

This library is free software; you can redistribute it and/or modify it under the terms of the BSD 3-Clause License.

=head1 SEE ALSO

=item kdtree L<<https://github.com/jtsiomb/kdtree>>

=end pod
