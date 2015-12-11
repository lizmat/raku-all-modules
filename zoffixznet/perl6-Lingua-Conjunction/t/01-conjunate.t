#!perl6

use v6;
use Test;
use lib 'lib';
use Lingua::Conjunction;

is conjunction(), '', 'no items';
is conjunction(<chair>), 'chair', 'single item';
is conjunction(<chair spoon>), 'chair and spoon', 'two items';
is conjunction(<chair spoon window>), 'chair, spoon, and window', 'three items';
is conjunction('Tom, a man', 'Tiffany, a woman', 'GumbyBRAIN, a bot'),
    'Tom, a man; Tiffany, a woman; and GumbyBRAIN, a bot',
    'commas in the input; we should use a semicolon to join them';

is conjunction(:str('Report[|s] for |list|'), <May June August>),
    'Reports for May, June, and August', 'custom string; multiple items';

is conjunction(:str('Report[|s] for |list|'), <May>),
        'Report for May', 'custom string; one item';

is conjunction(:str('Report[|s] for |list|')),
    'Reports for ', 'custom string uses plurals for zero-item lists';

is conjunction(<Squishy Slushi Sushi>,
            :str('|list| Octop[us|i] [is|are] named |list|')
), 'Squishy, Slushi, and Sushi Octopi are named Squishy, Slushi, and Sushi',
    'using special sequences in :str template multiple times works';

is (conjunction :lang<fr>,
    'Jacques, un garcon', 'Jeanne, une fille', 'Spot, un chien'
    ), 'Jacques, un garcon; Jeanne, une fille et Spot, un chien',
    'French version';

done-testing;
