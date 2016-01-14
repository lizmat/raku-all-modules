#!/usr/bin/env perl6
use v6;
use Data::Dump;
use JSON::Fast;

my @times = |from-json '_dev/tzs.json'.IO.slurp;
say Dump @times;


# for @times -> $zone {
    # say  $zone;
    # last;
    # say "Offset is $zone<offset>";
# }
