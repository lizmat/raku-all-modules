use v6.c;
use Test;
use Game::Sudoku;

my $game = Game::Sudoku.new();
is $game.Str,( "0" x 81 ), "Nothing to see here";
is $game.possible(0,0).sort,(1...9),"Everything is possible";

is $game.cell(0,0,1).Str,"1" ~ ( "0" x 80 ), "Setting returns the updated object";
is $game.cell(0,0),1,"Can also get a cells current value";
is $game.cell(0,1),Nil,"Requesting an unset cell returns Nil";
is $game.possible(0,0).sort,(),"We have no options";
is $game.possible(0,1).sort,(2...9),"We have options";
is $game.valid, True, "Game state is valid";

is $game.cell(0,0,2).Str,"2" ~ ( "0" x 80 ), "Now we have a cell";
is $game.possible(0,0).sort,(),"We have no options";
is $game.possible(0,1).sort,(1,3,4,5,6,7,8,9),"We have options";
is $game.valid, True, "Game state is valid";

is $game.cell(1,0,2).Str,"22" ~ ( 0 x 79 ), "Still getting games";
is $game.valid, False, "Game state is invalid as we have 2 2's";

my $code = "003020600900305001001806400008102900700000008006708200002609500800203009005010300",
$game =  Game::Sudoku.new( :code($code) );
is $game.Str, $code, "Game as expected";
is $game.possible(5,0),(1,4,7),"Got expected possibilites";

while [+] (^9 X ^9).map( -> ($x,$y) { ($x,$y) => $game.possible($x,$y) } ).grep( *.value.elems == 1 ).map( -> $p { my ( $x, $y ) = $p.key; $game.cell($x,$y,$p.value[0]); 1; } ) {
    ok $game.valid, "Game is valid"
}
ok $game.complete, "Game is complete";
ok $game.valid,    "Game is valid";
ok $game.full,     "Game is full";
is $game.Str, "483921657967345821251876493548132976729564138136798245372689514814253769695417382", "Got expected solution";

done-testing;
