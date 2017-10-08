#!perl6

use v6;
use Test;
use lib 'lib';
use Number::Denominate;

my %data = denominate 12661, :hash, :units(
    <hour hours> => 60,
    <minute minutes> => 60,
    <second seconds>
);

is-deeply %data, { hour => 3, minute => 31, second => 1 },
    'testing 12661 seconds';

is-deeply
    denominate( 12661, :hash, :units(hour => 60, minute => 60, <second>) ),
    %data,
    'testing unit shortcut';

is-deeply denominate( 12661, :hash, :set<time> ), %data,
    'testing unit set shortcut';

is-deeply denominate( 12661, :hash,
        :units( <mar meow> => 60, <ber beers> => 60, <foo bars> ),
    ), { mar => 3, ber => 31, foo => 1 },
    'testing "s"-less units';

is-deeply denominate( 12660, :hash, :set<time> ), { hour => 3, minute => 31 },
    'testing "missing" units, when their number is 0 [test 1]';

is-deeply denominate( 3*3600, :hash, :set<time> ), { hour => 3 },
    'testing "missing" units, when their number is 0 [test 2]';

is-deeply denominate( 0, :hash, :set<time> ), { },
    'testing "missing" units, when their number is 0 [test 3]';

is-deeply denominate( 3, :hash, :set<time> ), { second => 3 },
    'testing "missing" units, when their number is 0 [test 4]';

is-deeply denominate( 3601, :hash, :set<time> ), { hour => 1, second => 1 },
    'testing "missing" units, when their number is 0 [test 5]';

done-testing;
