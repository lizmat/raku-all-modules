#!/usr/bin/env perl6

use Time::Duration::Parser;

my $time-string = "5 days 4 hours 52 minutes 3 seconds";
my $s = duration-to-seconds($time-string);
say "$time-string -> $s seconds";



