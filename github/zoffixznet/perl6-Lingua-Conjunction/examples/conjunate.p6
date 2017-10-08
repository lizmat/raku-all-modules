use v6;
use lib 'lib';
use Lingua::Conjunction;

say conjunction <chair>; # chair
say conjunction <chair spoon>; # chair and spoon
say conjunction <chair spoon window>; # chair, spoon, and window

# "Tom, a man; Tiffany, a woman; and GumbyBRAIN, a bot"
say conjunction 'Tom, a man', 'Tiffany, a woman', 'GumbyBRAIN, a bot';

# Reports for May, June, and August
say conjunction <May June August>, :str('Report[|s] for |list|');

# "Jacques, un garcon; Jeanne, une fille et Spot, un chien"
say conjunction 'Jacques, un garcon', 'Jeanne, une fille', 'Spot, un chien',
    :lang<fr>;
