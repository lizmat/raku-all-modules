#!/usr/bin/env perl6

use lib '../lib';
use Green :harness;


ok 1 == 1;

ok 0 == 1;

>> {
  ok 0 == 1;
};
