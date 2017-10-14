use v6.c;

use Test;
use lib 'lib';
use TimeUnit;

plan 15;

is seconds.to-nanos(1), 1000 * 1000 * 1000, '1 sec to nonos';
is seconds.to-nanos(0.5), 500 * 1000 * 1000, 'half sec to nonos';
is days.to-seconds(15), 15 * 86400, '15 days to sec';
is micros.to-hours(hours.to-micros(5)), 5, '5 hours to microseconds and back';
is nanos.to-hours(432), 0.00000000012, '432 nanosecond to hours';
is hours.from(90, minutes), 1.5, '1.5 hours from 90 minutes';

is micros.from(:100nanos), 0.1, 'micros from named nanos';
is nanos.from(:100micros), 100 * 1000, 'nanos from named micros';
is millis.from(:99millis), 99, 'millis stay millis by named parameter';
is hours.from(:90minutes), 1.5, '1.5 hours from 90 minutes with named parameter';
is hours.from(:99seconds), 0.0275, 'little hours from named 99 seconds';
is minutes.from(:99hours), 5940, 'minutes from named 99 hours';
is seconds.from(days => 1.5), 129600, 'seconds from one and half named days';

dies-ok { minutes.from(:33hour) }, 'wrong named parameter';
dies-ok { minutes.from(hours => '5hours') }, 'parameter is not a number';

done-testing;