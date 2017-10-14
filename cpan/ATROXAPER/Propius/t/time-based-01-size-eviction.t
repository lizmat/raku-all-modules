#!/usr/bin/env perl6

use v6;
use Test;
use lib 'lib';
use Propius;

plan 8;

my @removed;
sub r-listener { push @removed, %(key => $:key, value => $:value, cause => $:cause); }
sub check-listener($key, $value, $cause) {
  @removed.elems === 1 && @removed.pop ~~ %(:$key, :$value, :$cause);
}

{
  my $cache = eviction-based-cache(
      loader => { $:key ** 2 },
      removal-listener => &r-listener,
      size => 3);

  $cache.get(3);
  $cache.get(4);
  $cache.get(5);
  is $cache.elems, 3, 'filled cache';

  $cache.get(6);
  ok check-listener(3, 9, Propius::RemoveCause::Size), 'removed first putted';

  $cache.get(4);
  $cache.get(7);
  is $cache.elems, 3, 'cache is not grows';
  ok check-listener(5, 25, Propius::RemoveCause::Size), 'removed the oldest accessed';

  $cache.get(7);
  $cache.get(6);
  $cache.get(4);
  is $cache.elems, 3, 'cache size the same';
  is +@removed, 0, 'no one has been removed';

  $cache.get(8);
  ok check-listener(7, 49, Propius::RemoveCause::Size), 'again removed the oldest accessed';

  is $cache.hash, %(4, 16, 6, 36, 8, 64), 'retrieve values by hash method';
}

done-testing;