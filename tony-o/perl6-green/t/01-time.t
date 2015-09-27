#!/usr/bin/env perl6

use lib 'lib';
use Test;
use Green;

plan 1;

my ($t0, $t1);
set(sub {
  test(sub ($done) {
    $t0 = now;
    sleep 1;
    $done();
  });
  test(sub ($done) {
    sleep 1;
    $t1 = now;
    ok 2500 > ($t1-$t0)*1000 > 1500, 'test time is ok';
    $done();
  });
});

