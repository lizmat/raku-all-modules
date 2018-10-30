#!/usr/bin/env perl6

use lib '../lib';
use Green :harness;


set('Async tests in series', sub {
  test('Sleep 1', -> $done {
    start { 
      sleep 1;
      ok 1==1;
      $done();
    };
  });

  test('Sleep 2', -> $done {
    start {
      sleep 2;
      ok 2 == 2;
      $done();
    };
  });
});

set('This happens async with the first set', sub {
  test('Sleep 1', -> $done {
    start {
      sleep 1;
      ok 1==1;
      $done();
    };
  });
});
