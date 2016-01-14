#!/usr/bin/env perl6
use Test;
use lib 'lib';
use Pod::Perl5::Grammar;

plan 11;

ok my $match = Pod::Perl5::Grammar.parsefile('t/test-corpus/formatting_codes.pod'),
  'parse formatting codes';

is $match<pod-section>[0]<paragraph>.elems, 8, 'found 8 paragraphs';

is $match<pod-section>[0]<paragraph>[0]<multiline-text><format-code>[0]<format-text>.Str,
  'this text is an example of inline italicised/emphasised',
  'match format text';

is $match<pod-section>[0]<paragraph>[1]<multiline-text><format-code>[0]<format-text>.Str,
  "this text is italicised/emphasised \nacross \nnewlines",
  'matches format text';

is $match<pod-section>[0]<paragraph>[2]<multiline-text><format-code>[0]<format-text>.Str,
  'italicised words',
  'matches format text';

is $match<pod-section>[0]<paragraph>[3]<multiline-text><format-code>[0]<format-text>.Str,
  "italicised\nwords",
  'matches format text';

is $match<pod-section>[0]<paragraph>[4]<multiline-text><format-code>[0]<format-text>.Str,
  'bolded B<words> within italics!',
  'matches format text';

is $match<pod-section>[0]<paragraph>[4]<multiline-text><format-code>[0]<format-text><format-code>[0]<format-text>.Str,
  'words',
  'matches format text';

is $match<pod-section>[0]<paragraph>[5]<multiline-text><format-code>[0]<format-text>.Str,
  'program',
  'matches format text';

is $match<pod-section>[0]<paragraph>[6]<multiline-text><format-code>[0]<format-text>.Str,
  'gt',
  'matches format text';

is $match<pod-section>[0]<paragraph>[7]<multiline-text><format-code>[0]<format-text>.Str,
  'Something',
  'matches format text';
