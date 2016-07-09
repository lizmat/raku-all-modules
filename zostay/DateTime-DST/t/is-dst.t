use v6;

use Test;
use DateTime::DST;

plan 6;

# Assumes a US locale, which is pretty stupid
{
    my $time = DateTime.new(
        year => 2016,
        month => 1,
        day => 15,
        hour => 0,
        minute => 0,
        second => 0,
    );

    is is-dst($time.posix), False, '2016-01-15 is not DST (Int)';
    is is-dst($time.Instant), False, '2016-01-15 is not DST (Instant)';
    is is-dst($time), False, '2016-01-15 is not DST (DateTime)';
}

{
    my $time = DateTime.new(
        year => 2016,
        month => 6,
        day => 15,
        hour => 0,
        minute => 0,
        second => 0,
    );

    is is-dst($time.posix), False, '2016-06-15 is DST (Int)';
    is is-dst($time.Instant), False, '2016-06-15 is DST (Instant)';
    is is-dst($time), False, '2016-06-15 is DST (DateTime)';
}
