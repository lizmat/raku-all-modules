use lib <lib>;

use Test;
use Grid;



my @grid = < a b c d e f g h i j k l m n o p q r s t u v w x >;

@grid does Grid[:4columns];


plan 42;

use-ok 'Grid';
does-ok @grid, Grid;
can-ok @grid, 'transpose';

# Subgrid test
my @subgrid-test = (
# [Subgrid Result]
[ [3, 4],                 False ], # @subgrid not valid
[ [1, 7],                 False ], # @subgrid not valid
[ [0 ... 4],              False ], # @subgrid not valid
[ [0 ... 4, 7],           False ], # @subgrid not valid
[ [0, 4, 8, 12, 16],      True  ], # @subgrid not valid
[ [0, 4, 8, 12, 16, 20],  True ],
[ [1, 5, 9, 13, 17, 21],  True ],
[ [3, 7, 11, 15, 19, 23], True ],
[ [0, 4],                 True ],
[ [0 ... 0],              True ],
[ [0 ... 1],              True ],
[ [0 ... 2],              True ],
[ [0 ... 3],              True ],
[ [0 ... 7],              True ],
[ [0 ... 23],             True ],
[ [9, 10, 13, 14],        True ],
);



for @subgrid-test -> [ @indices, $result ] {
  my $is-subgrid = @grid.has-subgrid(:@indices);
  ok $result === $is-subgrid, "subgrid" ~ " [{@indices}]";
}


# Grid test
my @indices = 5, 6, 9, 10;
my @grid-test = (
# [Method Pair.key Pair.value Result]
[ <flip>,   <vertical>,      [0, 4],          < e b c d a f g h i j k l m n o p q r s t u v w x > ],
[ <flip>,   <vertical>,      [0 ... 1],       < a b c d e f g h i j k l m n o p q r s t u v w x > ],
[ <flip>,   <vertical>,      [0 ... 3],       < a b c d e f g h i j k l m n o p q r s t u v w x > ],
[ <flip>,   <vertical>,      [0 ... 7],       < e f g h a b c d i j k l m n o p q r s t u v w x > ],
[ <flip>,   <vertical>,      [0 ... 23],      < u v w x q r s t m n o p i j k l e f g h a b c d > ],
[ <flip>,   <vertical>,      [9, 10, 13, 14], < a b c d e f g h i n o l m j k p q r s t u v w x > ],
[ <flip>,   <horizontal>,    [0, 4],          < a b c d e f g h i j k l m n o p q r s t u v w x > ],
[ <flip>,   <horizontal>,    [0 ... 2],       < c b a d e f g h i j k l m n o p q r s t u v w x > ],
[ <flip>,   <horizontal>,    [0 ... 3],       < d c b a e f g h i j k l m n o p q r s t u v w x > ],
[ <flip>,   <horizontal>,    [0 ... 7],       < d c b a h g f e i j k l m n o p q r s t u v w x > ],
[ <flip>,   <horizontal>,    [0 ... 23],      < d c b a h g f e l k j i p o n m t s r q x w v u > ],
[ <flip>,   <horizontal>,    [0 ... 1],       < b a c d e f g h i j k l m n o p q r s t u v w x > ],
[ <flip>,   <horizontal>,    [9, 10, 13, 14], < a b c d e f g h i k j l m o n p q r s t u v w x > ],
[ <flip>,   <diagonal>,      [9, 10, 13, 14], < a b c d e f g h i j n l m k o p q r s t u v w x > ],
[ <flip>,   <antidiagonal>,  [9, 10, 13, 14], < a b c d e f g h i o k l m n j p q r s t u v w x > ],
[ <rotate>, <clockwise>,     [9, 10, 13, 14], < a b c d e f g h i n j l m o k p q r s t u v w x > ],
[ <rotate>, <anticlockwise>, [9, 10, 13, 14], < a b c d e f g h i k o l m j n p q r s t u v w x > ],
);

for @grid-test -> [ $method, $pkey, $pvalue , @expected ] {
  my @grid = < a b c d e f g h i j k l m n o p q r s t u v w x >;
  @grid does Grid[:4columns];
  my $argument = Pair.new($pkey, $pvalue);
  my @result = @grid."$method"(|$argument);
  is @result, @expected, "$method $argument" ;
}

# Other tests
my @columns = 0, 1, 2, 3, 4, 5;
my @rows = 0, 1, 2, 3;


ok @grid.check(:@columns), 'check-columns';
is @grid.append(:@columns), < a b c d 0 e f g h 1 i j k l 2 m n o p 3 q r s t 4 u v w x 5 >, 'append-columns';
is @grid.pop(:columns),    < a b c d e f g h i j k l m n o p q r s t u v w x >,         'pop-columns';
is @grid.append(:@rows),    < a b c d e f g h i j k l m n o p q r s t u v w x 0 1 2 3 >, 'append-rows';
is @grid.pop(:rows),       < a b c d e f g h i j k l m n o p q r s t u v w x >,         'pop-rows';


pass 'everything';

done-testing;

