#!/usr/bin/env perl6
use Test;
use lib 'lib';
use Pod::Perl5::Grammar;

plan 4;

ok my $match = Pod::Perl5::Grammar.parsefile('t/test-corpus/paragraphs_advanced.pod'), 'parse paragraphs with verbatim example';

is $match<pod-section>[0]<paragraph>.elems, 2,
  'Parser extracted two paragraphs';

is $match<pod-section>[0]<verbatim-paragraph>.elems, 1,
  'Parser extracted one verbatim paragraph';

is $match<pod-section>[0]<verbatim-paragraph>.Str,
  qq/  use strict;\n  print "Hello, World!\\n";\n\n  some more code\n/,
  'Parser extracted the verbatim text';
