#!/usr/bin/env perl6

use lib '../lib';
use Green :harness;

ok 1 == 0, 'test';

>> sub {
  ok False;
}, 'not ok';
