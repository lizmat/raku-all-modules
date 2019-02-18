#!/usr/bin/env perl6

use lib <../lib>;
use Date::Names;

say "VERSION 2 ==================";
# notice three different ways to read the arrays:
my @dow = @($Date::Names::de::dow);
my $mon = $Date::Names::ru::mon;
my @h = $Date::Names::ru::mon;
say "ru mon elem:  $_" for @h;
 
say "German weekday names:";
for 1..7 -> $n {
    my $v = @dow[$n-1];
    say "  day $n: $v";
}
say "";
say "Russian month names:";
for 1..12  -> $n {
    my $v = $mon[$n];
    say "  month $n: $v";
}
