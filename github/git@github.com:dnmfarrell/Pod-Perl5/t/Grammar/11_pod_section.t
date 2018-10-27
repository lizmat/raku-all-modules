#!/usr/bin/env perl6
# this test checks if the Grammar can parse inline pod mixed with Perl 5 code

use Test;
use lib 'lib';
use Pod::Perl5::Grammar;

plan 4;

ok my $match = Pod::Perl5::Grammar.parsefile('t/test-corpus/Bar.pm'), 'parse Perl module with embedded pod';
is $match<pod-section>.elems, 3, 'Matched 3 pod sections';
is $match<pod-section>[1]<command-block>[0]<singleline-text>, 'bar', 'extracted "bar" head2 text';
is $match<pod-section>[1]<paragraph>[0]<multiline-text>,
  "Method to C<bar> a foo.\n", 'extracted "bar" method paragraph description';
