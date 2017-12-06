use v6.c;
use Test;
use Game::Sudoku;

# Empty board
my $game = Game::Sudoku.new();
is $game.Str, '0' x 81, "String rep is 81 0's";
my $expected =
"   |   |   \n"~
"   |   |   \n"~
"   |   |   \n"~
"---+---+---\n"~
"   |   |   \n"~
"   |   |   \n"~
"   |   |   \n"~
"---+---+---\n"~
"   |   |   \n"~
"   |   |   \n"~
"   |   |   ";

is $game.gist, $expected, "Grid is as expected";
is $game.valid, True, "Empty grid is valid";
is $game.complete, False, "Empty grid is not complete";   

$game = Game::Sudoku.new( code => ( "1" ~ ( "0" x 80 ) ) );
$expected =
"1  |   |   \n"~
"   |   |   \n"~
"   |   |   \n"~
"---+---+---\n"~
"   |   |   \n"~
"   |   |   \n"~
"   |   |   \n"~
"---+---+---\n"~
"   |   |   \n"~
"   |   |   \n"~
"   |   |   ";

is $game.Str, '1' ~ ( '0' x 80 ), "String rep is as expected";
is $game.gist, $expected, "Grid is as expected";

is $game.valid, True, "Grid is valid";
is $game.complete, False, "Grid is not complete";   

my $code = "483921657"~
           "967345821"~
           "251876493"~
           "548132976"~
	   "729564138"~
	   "136798245"~
	   "372689514"~
	   "814253769"~
	   "695417382";

$game = Game::Sudoku.new( code => $code );
$expected = "483|921|657\n"~
            "967|345|821\n"~
            "251|876|493\n"~
	    "---+---+---\n"~
            "548|132|976\n"~
	    "729|564|138\n"~
	    "136|798|245\n"~
	    "---+---+---\n"~
	    "372|689|514\n"~
	    "814|253|769\n"~
	    "695|417|382";

is $game.Str, $code, "String rep is as expected";
is $game.gist, $expected, "Grid is as expected";

is $game.valid, True, "Grid is valid";
#todo "Grid completion not coded yet";
is $game.complete, True, "Grid is complete.";   



done-testing;
