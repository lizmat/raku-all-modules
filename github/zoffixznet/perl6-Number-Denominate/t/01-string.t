#!perl6

use v6;
use Test;
use lib 'lib';
use Number::Denominate;

my $data = denominate 12661, :units(
    <hour hours> => 60, <minute minutes> => 60, <second seconds>
);

is $data, '3 hours, 31 minutes, and 1 second', '12661 seconds';
is denominate( 12661, :units(hour => 60, minute => 60, 'second') ), $data,
    'unit plurality shortcut';

is denominate( 12661, :set<time> ), $data, '"time" units set';
is denominate( 12661             ), $data, '"time" units set is default set';

is denominate( 12661, :units(<mar meow> => 60, <ber beers> => 60, <foo bars>) ),
    '3 meow, 31 beers, and 1 foo', 'testing "s"-less units';

is denominate( 12660, :units( hour => 60, minute => 60, 'second' ) ),
    '3 hours and 31 minutes',
    'testing "missing" units, when their number is 0 [test 1]';

is denominate( 0 ), '0 seconds',
    'testing "missing" units, when their number is 0 [test 2]';

is denominate( 60 ), '1 minute',
    'testing "missing" units, when their number is 0 [test 3]';

is denominate( 62 ), '1 minute and 2 seconds',
    'testing "missing" units, when their number is 0 [test 4]';

is denominate( 3601 ), '1 hour and 1 second',
    'testing "missing" units, when their number is 0 [test 5]';

is denominate( 21212121, :set<weight> ),
    '21 tonnes, 212 kilograms, and 121 grams', 'weight units';

done-testing;
