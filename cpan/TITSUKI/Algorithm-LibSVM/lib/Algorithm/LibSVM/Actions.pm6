use v6;
unit class Algorithm::LibSVM::Actions:ver<0.0.2>;

method TOP($/) { make $<bodylist>.made }
method bodylist($/) { make $<body>>>.made }
method body($/) { make { label => $<number>.Num, pairs => $<pairlist>.made } }
method pairlist($/) { make $<pair>>>.made }
method pair($/) { make $<key>.Int => $<value>.Num }

=begin pod

=head1 NAME

Algorithm::LibSVM::Actions - A Perl 6 Algorithm::LibSVM::Actions class

=head1 SYNOPSIS

  use Algorithm::LibSVM::Actions;

=head1 DESCRIPTION

Algorithm::LibSVM::Actions is a Perl 6 Algorithm::LibSVM::Actions class

=head1 AUTHOR

titsuki <titsuki@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2016 titsuki

This library is free software; you can redistribute it and/or modify it under the terms of the MIT License.

libsvm ( https://github.com/cjlin1/libsvm ) by Chih-Chung Chang and Chih-Jen Lin is licensed under the BSD 3-Clause License.

=end pod
