#!/usr/bin/env perl6

use v6;

sub MAIN (
  Str:D $include-file where .IO ~~ :r,
  Str:D $store-path where .IO ~~ :d
) {

  my Str $pm6-file = $store-path ~ '/' ~ $include-file.IO.basename.tc;
  $pm6-file ~~ s/\. <-[\.]>* $/.pm6/;

  my Str $module = $pm6-file.tc;
  $module ~~ s:i/^ lib \/ //;
  $module ~~ s:g/ \/ /::/;
  $module ~~ s/\. <-[\.]>* $//;

  my Str $p6 = Q:qq:to/EOUNIT/;
    use v6;

    unit module $module;

    EOUNIT

  my Int $count = 0;

  for $include-file.IO.lines -> $line {

    # convert '#define GDK_KEY_Bluetooth 0x1008ff94'
    # into 'constant GDK_KEY_Bluetooth = 0x1008ff94;'
    if $line ~~ m/^ '#define' \s+ (<-[\s]>+) \s+ (.+) $/ {

      say "Converting '$line'";

      my Str $variable = $/[0].Str;
      my Str $value = $/[1].Str;
      $p6 ~= "constant $variable is export = $value;\n";
      $count++;
    }
  }

  $pm6-file.IO.spurt( "$p6");

  say "\n$count lines converted\nLines are stored in '$pm6-file'";
}
