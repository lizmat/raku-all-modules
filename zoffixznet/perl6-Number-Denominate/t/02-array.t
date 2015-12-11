#!perl6

use v6;
use Test;
use lib 'lib';
use Number::Denominate;

is-deeply denominate( 12661, :array ), [
    {:denomination(7),  :plural("weeks"),   :singular("week"),   :value(0) },
    {:denomination(24), :plural("days"),    :singular("day"),    :value(0) },
    {:denomination(60), :plural("hours"),   :singular("hour"),   :value(3) },
    {:denomination(60), :plural("minutes"), :singular("minute"), :value(31)},
    {:denomination(1),  :plural("seconds"), :singular("second"), :value(1) }
], '12661 seconds';

is-deeply denominate( 3*60*60, :array ), [
    {:denomination(7),  :plural("weeks"),   :singular("week"),   :value(0) },
    {:denomination(24), :plural("days"),    :singular("day"),    :value(0) },
    {:denomination(60), :plural("hours"),   :singular("hour"),   :value(3) },
    {:denomination(60), :plural("minutes"), :singular("minute"), :value(0) },
    {:denomination(1),  :plural("seconds"), :singular("second"), :value(0) }
], '3 hours';

done-testing;
