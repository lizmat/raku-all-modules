#! /usr/bin/env perl6
use v6;
use Test;

use-ok('ScaleVec::Scale::Fence');
use ScaleVec::Scale::Fence;

my $lower-limit = 0;
my $upper-limit = 128;
my $repeat-interval = 12;

my ScaleVec::Scale::Fence $fence .= new(:$lower-limit :$upper-limit :$repeat-interval);

is $fence.defined, True, "Fence created OK";

is $fence.step(1),    1,    "Step 1 unchanged";
is $fence.step(126),  126,  "Step 126 unchanged";
is $fence.step(0),    0,    "Step 0 unchanged (lower-limit)";
is $fence.step(127),  127,  "Step 127 unchanged (upper-limit)";

is $fence.step(128),  116,  "Step 128 -> 116";
is $fence.step(130),  118,  "Step 130 -> 118";
is $fence.step(141),  117,  "Step 141 -> 117";

is $fence.step(-1),   11,   "Step -1 -> 11";
is $fence.step(-3),   9,    "Step -3 -> 9";
is $fence.step(-14),  10,    "Step -14 -> 10";

#Test pitch class conversion
my ScaleVec::Scale::Fence $pitch-classes .= new(
  :repeat-interval(12)
  :lower-limit(0)
  :upper-limit(12)
);

my @pitches = do $pitch-classes.step($_) for -48..48;
ok @pitches.all == any(0..11), "Pitches -48..48 convert to pitch classes recieved({ @pitches.join: ", " })";

done-testing;
