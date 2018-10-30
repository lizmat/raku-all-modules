#!/usr/bin/env perl6
use Test;
use lib 'lib';
use Pod::Perl5::Grammar;

plan 6;

ok my $match = Pod::Perl5::Grammar.parsefile('t/test-corpus/begin_end.pod'), 'parse begin/end command';
is $match<pod-section>[0]<command-block>.elems, 2, 'Parser extracted two begin/end pairs';

# block 1
is $match<pod-section>[0]<command-block>[0]<begin><name>.Str, 'HTML', 'The name from first begin pair is HTML';
is $match<pod-section>[0]<command-block>[0]<begin-end-content>.Str,
  qq/\n<a href="">Some link<\/a>\n\n/,
  'Extract the text from begin/end block';

# block 2
is $match<pod-section>[0]<command-block>[1]<begin><name>.Str, 'some_text', 'The name from first begin pair is some_text';
is $match<pod-section>[0]<command-block>[1]<begin-end-content>.Str,
  "\nThis is just some text\n\n",
  'Extract the text from begin/end block';

