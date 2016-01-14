#!/usr/bin/env perl6
use Test;
use lib 'lib';
use Pod::Perl5::Grammar;

plan 3;

ok my $match = Pod::Perl5::Grammar.parsefile('t/test-corpus/command.pod'), 'parse command';

is $match<pod-section>[0]<command-block>.elems, 2, 'Parser extracted three command paragraphs';

is $match<pod-section>[0]<command-block>[1]<name>.Str, 'utf8', 'Parser extracted encoding name is utf8';

