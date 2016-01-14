#!/usr/bin/env perl6
use Test;
use lib 'lib';
use Pod::Perl5::Grammar;

plan 4;

ok my $match = Pod::Perl5::Grammar.parsefile('t/test-corpus/for.pod'), 'parse for command';

is $match<pod-section>[0]<command-block>.elems, 1, 'Parser extracted one for';
is $match<pod-section>[0]<command-block>[0]<name>.Str, 'HTML', 'Parser extracted name value is HTML';
is $match<pod-section>[0]<command-block>[0]<singleline-text>.Str, "<a href='#'>some inline hyperlink</a>", 
  'Parser extracted the paragraph';
