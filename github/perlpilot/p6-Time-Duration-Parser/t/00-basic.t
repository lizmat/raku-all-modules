#!/usr/bin/env perl6

use Test;
use Time::Duration::Parser;

my @tests = (
    [ "1 s", 1 ],
    [ "1 sec", 1 ],
    [ "1 secs", 1 ],
    [ "1 second", 1 ],
    [ "1 seconds", 1 ],
    [ "33 seconds", 33 ],

    [ "1 m", 60 ],
    [ "1 min", 60 ],
    [ "1 mins", 60 ],
    [ "1 minute", 60 ],
    [ "1 minutes", 60 ],
    [ "15 minutes", 60 * 15 ],

    [ "1 h", 3600 ],
    [ "1 hr", 3600 ],
    [ "1 hrs", 3600 ],
    [ "1 hour", 3600 ],
    [ "1 hours", 3600 ],
    [ "4 hours", 3600 * 4 ],

    [ "1 d", 86400 ],
    [ "1 day", 86400 ],
    [ "1 days", 86400 ],
    [ "3 days", 86400 * 3 ],

    [ "1 w", 86400 * 7 ],
    [ "1 week", 86400 * 7 ],
    [ "1 weeks", 86400 * 7 ],
    [ "2 weeks", 86400 * 7 * 2 ],

    [ "1 M", 86400 * 30 ],
    [ "1 mo", 86400 * 30 ],
    [ "1 mon", 86400 * 30 ],
    [ "1 mons", 86400 * 30 ],
    [ "1 month", 86400 * 30 ],
    [ "1 months", 86400 * 30 ],
    [ "9 months", 86400 * 30 * 9 ],

    [ "1 y", 86400 * 365 ],
    [ "1 year", 86400 * 365 ],
    [ "1 years", 86400 * 365 ],
    [ "12 years", 86400 * 365 * 12 ],

    [ "1 day 1 sec", 86401 ],
    [ "1 day 1 second", 86401 ],
    [ "1 day 1 min", 86460 ],
    [ "1 day 1 minute", 86460 ],
    [ "1 day 3 minutes 15 seconds", 86400  + 3 * 60 + 15 ],
);


for @tests -> ($str, $expected-sec) {
    my $actual-sec = duration-to-seconds($str);
    is $actual-sec, $expected-sec, "$str ~> $expected-sec seconds";
}

done-testing;
