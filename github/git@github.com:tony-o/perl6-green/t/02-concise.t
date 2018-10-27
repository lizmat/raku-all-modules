#!/usr/bin/env perl6

use Green;
use Test;


my $i = 0;

>> {
  plan 3;
  ok 1 == ++$i;
};

>> {
  ok 2 == ++$i;
}

>> {
  ok 3 == ++$i;
}
