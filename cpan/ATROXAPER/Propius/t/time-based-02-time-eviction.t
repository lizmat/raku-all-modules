#!/usr/bin/env perl6

use v6;
use Test;
use TimeUnit;
use lib 'lib';
use Propius;

plan 19;

my @removed;
sub r-listener { push @removed, %(key => $:key, value => $:value, cause => $:cause); }
sub check-listener($key, $value, $cause) {
  for ^@removed {
    if @removed[$_] ~~ %(:$key, :$value, :$cause) {
      @removed.splice($_, 1);
      return True;
    }
  }
  return False;
}

my Int $now;
class Ticker does Propius::Ticker {
  method now(--> Int) {
    $now;
  }
}

{
  my $cache = eviction-based-cache(
      loader => { $:key ** 2 },
      removal-listener => &r-listener,
      expire-after-write => 30,
      expire-after-access => 18,
      ticker => Ticker.new);

  $now = 10;
  $cache.get(1); # w10 a10
  $now = 20;
  $cache.get(2); # w20 a20
  $cache.get(1); # w10 a20
  $now = 30;
  $cache.get(3); # w30 a30
  $cache.get(2); # w20 a30 --
  $cache.get(1); # w10 a30 --
  $now = 45;
  $cache.get(4); # w45 a45
  ok check-listener(1, 1, Propius::RemoveCause::Expired), 'expired 1 by write';

  $cache.get(3); # w40 a45
  $now = 49;
  $cache.get(5); # w49 a49
  ok check-listener(2, 4, Propius::RemoveCause::Expired), 'expired 2 by access';

  $cache.get(3); # w30 a49 --
  $cache.get(4); # w45 a49 --
  $now = 69;
  $cache.get(6); # w69 a69
  ok check-listener(5, 25, Propius::RemoveCause::Expired), 'expired 5 by access';
  ok check-listener(3, 9, Propius::RemoveCause::Expired), 'expired 3 by write';
  ok check-listener(4, 16, Propius::RemoveCause::Expired), 'expired 4 by access';
  is $cache.elems, 1, 'only 6 left in cache';
  is @removed.elems, 0, 'no any removed elems';

  $now = 100;
  $cache.clean-up();
  ok check-listener(6, 36, Propius::RemoveCause::Expired), 'expired 6 any way';
  is $cache.elems, 0, 'zero elems after all expired';

  $cache.get(7);
  is $cache.elems, 1, 'one element after all expired and store again';
}

{
  my $cache = eviction-based-cache(
      loader => { $:key ** 2 },
      removal-listener => &r-listener,
      expire-after-access => 20,
      time-unit => seconds,
      ticker => Ticker.new);

  $now = 10;
  $cache.get(3);
  $now = 20;
  $cache.get(4);
  $cache.clean-up();
  is $cache.elems, 2, 'store two elements';
  is +@removed, 0, 'no one elements were cleaned';

  $now = 35;
  $cache.get(4) for ^20;
  is $cache.elems, 1, 'one element was cleaned by multi read';
  ok check-listener(3, 9, Propius::RemoveCause::Expired), 'expired 3 by access';

  $now = 56;
  $cache.get(5);
  is $cache.elems, 1, 'second element was cleaned by write';
  ok check-listener(4, 16, Propius::RemoveCause::Expired), 'expired 4 by write';

  is $cache.get-if-exists(5), 25, '5 is exists';
  is $cache.get-if-exists(4), Any, '4 is not exists';

  is $cache.hash, %(5, 25), 'retrieve only one value by hash method';
}

done-testing;