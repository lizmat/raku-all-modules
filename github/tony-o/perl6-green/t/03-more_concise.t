#!/usr/bin/env perl6

use lib 'lib';
use Test;
plan 1;

{
  use Green :harness;
  ok 1 == 1;
}; #this should get handled by Green's ok and not kill global

ok 1 == 1;
