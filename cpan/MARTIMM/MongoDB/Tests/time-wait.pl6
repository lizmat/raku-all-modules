#!/usr/bin/env perl6

use v6;

my Hash $sleep-wait = {
  :s1(4.3), :s2(2.1), :s3(5.3), :s4(10.4), :s5(8.7),
};

my Hash $sleep-left = %(|$sleep-wait);

loop {

#  my Duration $now .= new(now);

  # get shortest sleep
  my $t = 1_000_000.0;
  my $s;
  for $sleep-left.keys -> $k {
    if $sleep-left{$k} < $t {
      $t = $sleep-left{$k};
      $s = $k;
    }
  }

  # set back to original time
  $sleep-left{$s} = $sleep-wait{$s};
  note "Reset entry $s to $sleep-left{$s} (from $sleep-wait{$s})";

  # adjust remaining entries
  for $sleep-left.keys -> $k {
    next if $s eq $k;
    $sleep-left{$k} -= $t;
    $sleep-left{$k} = 0.001 if $sleep-left{$k} <= 0;
  }

  note "sleep for $t sec, entry $s";
  sleep $t;

#  note "T: ", (now - $now).Str;
}
