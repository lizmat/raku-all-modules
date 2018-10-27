#!/usr/bin/env perl6

use lib '../lib';
use Green :harness;

#all of these tests should complete in 2 seconds
>> {
  sleep 2;
  ok 1 == 1;
};

>> {
  sleep 2;
  ok 1 == 1;
};
>> {
  sleep 2;
  ok 1 == 1;
};


>> { 1 == 1; }
