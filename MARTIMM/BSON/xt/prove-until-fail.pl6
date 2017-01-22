#!/usr/bin/env perl6

use v6.c;

sub MAIN ( Str:D $filename where (.IO ~~ :r and .IO !~~ :d) ) {

  my Proc $p;

  my Bool $success = True;
  while $success {
    $p = shell "prove --merge -v -e perl6 $filename";
    $success = $p.exitcode eq 0;
  }
}
