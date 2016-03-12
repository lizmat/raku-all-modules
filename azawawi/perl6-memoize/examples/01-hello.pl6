#!/usr/bin/env perl6

use v6;

use lib 'lib';
use Memoize;

sub get-slowed-result(Int $n where $_ >= 0) is memoized(:cache_size(10), :cache_strategy("LRU"), :debug) {
  sleep $n / 10;
  return 1 if $n <= 1;
  return get-slowed-result($n - 1) * $n;
}

say sprintf("get-slowed-result(%d) is %d", $_, get-slowed-result($_)) for 0..10;
