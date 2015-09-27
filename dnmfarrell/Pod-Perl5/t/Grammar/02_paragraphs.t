#!/usr/bin/env perl6
use Test;
use lib 'lib';
use Pod::Perl5::Grammar;

plan 5;

ok my $match = Pod::Perl5::Grammar.parsefile('test-corpus/paragraphs_simple.pod'), 'parse paragraphs';

is $match<pod-section>[0]<paragraph>.elems, 3, 'Parser extracted three paragraphs';

is $match<pod-section>[0]<paragraph>[0].Str,
  "paragraph one\n", 'Paragraph text extracted successfully';

is $match<pod-section>[0]<paragraph>[1].Str,
  "paragraph two\nparagraph two\n", 'Paragraph text extracted successfully';

is $match<pod-section>[0]<paragraph>[2].Str,
  "paragraph three\nparagraph three\nparagraph three\n", 'Paragraph text extracted successfully';

