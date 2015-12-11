#!perl6

use v6;
use Test;
use lib 'lib';
use WWW::Google::Time;

my %time = ( google-time-in 'Toronto' orelse do {
    $_.exception.message ~~ /Network/
        ?? skip-rest "Got network error: {$_.exception.message}"
        !! die "Did not get time data, but we should have! "
            ~ $_.exception.message
});

is %time.keys.elems, 8, 'Our time hash has 8 items in it';

like %time<month>, /^[January|February|March|April|May|June|July|August|
    September|October|November|December]$/, 'month looks right';

cmp-ok %time<month-day>, &infix:['>='],  1, 'month day is >= 1';
cmp-ok %time<month-day>, &infix:['<='], 31, 'month day is <= 31';
like   %time<time>,  /^ \d\d? ':' \d**2 ' ' [AM | PM] $/, 'time looks right';
like   %time<tz>,    /^ [EST | EDT] $/,     'timezone looks right';
like   %time<where>, /'Toronto, ON'/,       'where looks right';
like   %time<year>,  /^20 \d**2 $/,         'year looks right';

like %time<week-day>,
    /^[Sunday|Monday|Tuesday|Wednesday|Thursday|Friday|Saturday]$/,
    'day of the week looks right';

is %time<str>, "%time<time> %time<tz>, %time<week-day>, %time<month> "
    ~ "%time<month-day>, %time<year>", 'str looks right';

done-testing;
