#!/usr/bin/env perl6

use lib '../lib';
use Green :harness;

#all of these tests should complete in 2 seconds
set("time me 1", sub {
  test("delay 2", sub {
    sleep 2;
    ok 1==1;
  });
});
set("time me 2", sub {
  test("delay 2", sub {
    sleep 2;
    ok 1==1;
  });
});
set("time me 3", sub {
  test("delay 2", sub {
    sleep 2;
    ok 1==1;
  });
});
set("time me 4", sub {
  test("delay 2", sub {
    sleep 2;
    ok 1==1;
  });
});

