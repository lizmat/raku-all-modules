#!/usr/bin/env perl6
use Test;
use lib 'lib';
use Pod::Perl5::Grammar;

plan 17;

ok my $match = Pod::Perl5::Grammar.parsefile('test-corpus/over_back.pod'), 'parse over_back';
is $match<pod-section>[0]<command-block>.elems, 3, 'Parser extracted three over/back pairs';

# tests for list 1
is $match<pod-section>[0]<command-block>[0]<_item>[0]<bullet-point>.Str, '1',
  'Parser extracted bullet-point from bullet point one';

is $match<pod-section>[0]<command-block>[0]<_item>[0]<multiline-text>.Str, "bullet point one\n",
  'parser extracted paragraph from bullet point one';

is $match<pod-section>[0]<command-block>[0]<_item>[1]<bullet-point>.Str, '2',
  'Parser extracted bullet-point from bullet point two';

is $match<pod-section>[0]<command-block>[0]<_item>[1]<multiline-text>.Str, "bullet point two\n",
  'Parser extracted paragraph from bullet point two';

is $match<pod-section>[0]<command-block>[0]<_item>[2]<bullet-point>.Str,
  '*',
  'Parser extracted bullet-point from bullet point three';

is $match<pod-section>[0]<command-block>[0]<_item>[2]<multiline-text>.Str,
  "bullet point three\n",
  'Parser extracted paragraph from bullet point three';

is $match<pod-section>[0]<command-block>[0]<_item>[3]<bullet-point>.Str,
  '*',
  'Parser extracted bullet-point from bullet point four';

is $match<pod-section>[0]<command-block>[0]<_item>[4]<bullet-point>.Str,
  '0',
  'Parser extracted bullet-point from bullet point five';

is $match<pod-section>[0]<command-block>[0]<_item>[5]<bullet-point>,
  '345',
  'Parser extracted bullet-point from bullet point six';

is $match<pod-section>[0]<command-block>[0]<_item>[5]<paragraph>[0]<multiline-text>.Str,
  "paragraph one\n",
  'Parser extracted paragraph from bullet point seven';

is $match<pod-section>[0]<command-block>[0]<_item>[6]<bullet-point>,
  '*',
  'Parser extracted bullet-point from bullet point seven';

# tests for list 3
is $match<pod-section>[0]<command-block>[1]<over>.Str,
  "=over 4\n",
  'Extracted the over and the number';

is $match<pod-section>[0]<command-block>[1]<_item>.elems,
  3, 'Extracted three items from the second list';

# tests for list 3
is $match<pod-section>[0]<command-block>[2]<command-block>[0]<_item>.elems,
  2, 'The inner list has two items';

is $match<pod-section>[0]<command-block>[2]<_item>.elems,
  3, 'The outer list has three items';
