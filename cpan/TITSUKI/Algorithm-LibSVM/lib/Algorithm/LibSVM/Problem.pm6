use v6;
use NativeCall;
use Algorithm::LibSVM::Node;
use NativeHelpers::Array;

unit class Algorithm::LibSVM::Problem:ver<0.0.2> is export is repr('CStruct');

has int32 $.l;
has CArray[num64] $!y;
has CArray[Algorithm::LibSVM::Node] $!x;

method BUILD(int32 :$l, CArray[num64] :$y, CArray[Algorithm::LibSVM::Node] :$x) {
    $!l = $l;
    $!y := $y;
    $!x := $x;
}

method y returns Array {
    copy-to-array($!y, $!l);
}

method x returns Array {
    copy-to-array($!x, $!l);
}

=begin pod

=head1 NAME

Algorithm::LibSVM::Problem - A Perl 6 Algorithm::LibSVM::Problem class

=head1 SYNOPSIS

  use Algorithm::LibSVM::Problem;

=head1 DESCRIPTION

Algorithm::LibSVM::Problem is a Perl 6 Algorithm::LibSVM::Problem class

=head2 METHODS

=head3 l

Defined as:

        method l returns Int:D

Returns the number of the training data.

=head3 y

Defined as:

        method y returns Array

Returns the array containing the target values (C<Int> values in classification, C<Num> values in regression) of the training data.

=head3 x

Defined as:

        method x returns Array

Returns the array of pointers, each of which points to a sparse representation (i.e. array of C<Algorithm::LibSVM::Node>) of one training vector.

=head1 AUTHOR

titsuki <titsuki@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2016 titsuki

This library is free software; you can redistribute it and/or modify it under the terms of the MIT License.

libsvm ( https://github.com/cjlin1/libsvm ) by Chih-Chung Chang and Chih-Jen Lin is licensed under the BSD 3-Clause License.

=end pod
