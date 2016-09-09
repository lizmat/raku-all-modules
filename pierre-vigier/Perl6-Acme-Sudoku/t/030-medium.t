use v6;
use Test;
use Acme::Sudoku;

plan 1;

my $game = Acme::Sudoku.new( q:to/END/ );
2 . . 1 7 . 6 . 3
. 5 . . . . 1 . .
. . . . . 6 . 7 9
. . . . 4 . 7 . .
. . . 8 . 1 . . .
. . 9 . 5 . . . .
3 1 . 4 . . . . .
. . 5 . . . . 6 .
9 . 6 . 3 7 . . 2
END
$game.solve;

my $solution = Acme::Sudoku.new( q:to/END/ );
2 9 8 1 7 5 6 4 3
6 5 7 3 9 4 1 2 8
1 3 4 2 8 6 5 7 9
8 2 1 6 4 9 7 3 5
5 7 3 8 2 1 4 9 6
4 6 9 7 5 3 2 8 1
3 1 2 4 6 8 9 5 7
7 8 5 9 1 2 3 6 4
9 4 6 5 3 7 8 1 2
END

ok $game ~~ $solution, "Solution is correct";

say $game;
#say "Elapsed : ";
#say now - BEGIN { now };
