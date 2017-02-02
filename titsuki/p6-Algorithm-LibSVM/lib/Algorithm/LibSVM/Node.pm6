use v6;

unit class Algorithm::LibSVM::Node is export is repr('CStruct');

has int32 $.index;
has num64 $.value;
has Algorithm::LibSVM::Node $.next;

submethod BUILD(Int:D :$!index, Num:D :$!value, Algorithm::LibSVM::Node :$next) {
    $!next := $next;
}

=begin pod

=head1 NAME

Algorithm::LibSVM::Node - A Perl 6 Algorithm::LibSVM::Node class

=head1 SYNOPSIS

  use Algorithm::LibSVM::Node;

=head1 DESCRIPTION

Algorithm::LibSVM::Node is a Perl 6 Algorithm::LibSVM::Node class

=head2 METHODS

=head3 index

Defined as:

        method index returns Int:D

=head3 value

Defined as:

        method value returns Num:D

=head1 AUTHOR

titsuki <titsuki@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2016 titsuki

This library is free software; you can redistribute it and/or modify it under the terms of the MIT License.

libsvm ( https://github.com/cjlin1/libsvm ) by Chih-Chung Chang and Chih-Jen Lin is licensed under the BSD 3-Clause License.

=end pod
