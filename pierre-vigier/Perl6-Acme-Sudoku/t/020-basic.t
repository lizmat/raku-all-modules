use v6;
use Test;
use Acme::Sudoku;

plan 3;

my $ok-grid = q:to/END/;
. . . . . 8 . . .
7 . . . . . 9 . 5
. 1 4 . 3 5 8 . .
. 2 . . 1 6 . 3 .
. 5 . . . 9 6 . 1
8 . . . . . . . 4
3 . 9 2 . . 1 . .
. . 6 1 . 7 . . 2
1 . . 5 . . . 7 .
END

my $non-parsable-grid = q:to/END/;
1 2 3 4
5 4 3 2
END

my $match = Acme::Sudoku::SudokuGrid.parse( $non-parsable-grid );
nok so $match, "Can't parse a wrong size grid";

$match = Acme::Sudoku::SudokuGrid.parse( $ok-grid );
ok so $match, "Can parse a valid grid";

my $game = Acme::Sudoku.new( $ok-grid );
my $solution = Acme::Sudoku.new( q:to/END/ );
6 9 5 7 4 8 2 1 3
7 3 8 6 2 1 9 4 5
2 1 4 9 3 5 8 6 7
9 2 7 4 1 6 5 3 8
4 5 3 8 7 9 6 2 1
8 6 1 3 5 2 7 9 4
3 7 9 2 8 4 1 5 6
5 4 6 1 9 7 3 8 2
1 8 2 5 6 3 4 7 9
END

$game.solve();

ok $game ~~ $solution, "Solve found the correct solution";

