#!/usr/bin/env perl6

use lib <../lib>;
use Date::Names;

my %dow = %Date::Names::dow<de>;

my %mon = %Date::Names::mon<ru>;

say "German weekday names:";
for 1..7 -> $n {
    my $v = %dow{$n};
    say "  day $n: $v";
}

say "";
say "Russian month names:";
for 1..12  -> $n {
    my $v = %mon{$n};
    say "  month $n: $v";
}
