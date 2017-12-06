use v6.c;
use Test;
use Game::Sudoku;

# Puzzles are valid if there are 0-1 of any number in any possibly area.

# Valid puzzles
my @valid = (
    "0" x 81,
    ( "1" ~ ( "0" x "80" ) ),
    ( "123" ~ ( "0" x "78" ) ),
    "483921657967345821251876493548132976729564138136798245372689514814253769695417382",
    "003020600900305001001806400008102900700000008006708200002609500800203009005010300",
);

for @valid -> $code {
    my $game = Game::Sudoku.new( code => $code );
    is $game.valid, True, "$game is valid";
}

# Invalid Puzzles

my @invalid = ( 
    ( "11" ~ ( "0" x "79" ) ),
    ( "123000000123000000" ~ ( "0" x "63" ) ),
    "843921657967345821251876493548132976729564138136798245372689514814253769695417382",
    "003020600900305001001806400008102900700000008006708200002609500800203009005010303",
);

for @invalid -> $code {
    my $game = Game::Sudoku.new( code => $code );
    is $game.valid, False, "$game is invalid";
}



done-testing;
