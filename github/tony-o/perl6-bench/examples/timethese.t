#!/usr/bin/env perl6

use lib 'lib';
use Bench;

my $b = Bench.new(:debug(False));

my $r = $b.timethese(50, {
  hades => sub{
    sleep .005;
  },
  sleeper => sub{
    sleep .005
  },
});

