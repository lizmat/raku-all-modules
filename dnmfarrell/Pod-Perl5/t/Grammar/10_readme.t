#!/usr/bin/env perl6
use Test;
use lib 'lib';
use Pod::Perl5::Grammar;

plan 9;

ok my $match = Pod::Perl5::Grammar.parsefile('test-corpus/readme_example.pod'),
  'parse readme example';

# basic counts
is $match<pod-section>.elems,                       1, 'Parser extracted one pod section';
is $match<pod-section>[0]<command-block>.elems,     12, 'Parser extracted command blocks';
is $match<pod-section>[0]<paragraph>.elems,         6, 'Parser extracted six paragraphs';
is $match<pod-section>[0]<verbatim-paragraph>.elems,1, 'Parser extracted four verbatim paragraphs';

# value checks
is $match<pod-section>[0]<command-block>[5]<singleline-text>.Str,
  "SYNOPSIS",
  'Parser extracted name from header';

is $match<pod-section>[0]<paragraph>[2]<multiline-text>.Str,
  "0.01\n",
  'Parser extracted text from paragraph';

is $match<pod-section>[0]<paragraph>[3]<multiline-text><format-code>[1]<format-text>.Str,
  "Pod::Perl5::Grammar",
  'Parser extracted value from code formatting';

is $match<pod-section>[0]<verbatim-paragraph>[0]<verbatim-text-line>[0].Str,
  "  use Pod::Perl5;\n",
  'Parser extracted text from verbatim paragraph';
