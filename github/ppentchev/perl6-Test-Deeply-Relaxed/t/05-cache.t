#!/usr/bin/env perl6

use v6.c;

use Test;

use Test::Deeply::Relaxed;

plan 14;

my $seq = (1, 2, 3).Seq;
my $list = list(1, 2, 3);
my $v = 42;

is-deeply-relaxed $seq, $list, 'non-cached - same';
is-deeply $list, list(1, 2, 3), 'non-cached - preserved the list';
dies-ok { $v = $seq.cache.iterator.pull-one }, 'non-cached - did not preserve the sequence';
is $v, 42, 'non-cached - did not pull anything out of the sequence';
dies-ok { $v = $seq.iterator.pull-one }, 'non-cached - did not preserve the sequence outside the cache';
is $v, 42, 'non-cached - did not pull anything out of the sequence outside the cache';

$seq = (1, 2, 3).Seq;
is-deeply-relaxed $seq, $list, :cache, 'cached - same';
is-deeply $list, list(1, 2, 3), 'cached - preserved the list';
lives-ok { $v = $seq.cache.iterator.pull-one }, 'cached - preserved the sequence';
is $v, 1, 'cached - pulled the correct value out of the sequence';

$seq = (1, 5, 3).Seq;
isnt-deeply-relaxed $seq, $list, :cache, 'cached-diff - different';
is-deeply $list, list(1, 2, 3), 'cached-diff - preserved the list';
$v = 42;
lives-ok { $v = $seq.cache.iterator.pull-one }, 'cached-diff - preserved the sequence';
is $v, 1, 'cached-diff - pulled the correct value out of the sequence';
