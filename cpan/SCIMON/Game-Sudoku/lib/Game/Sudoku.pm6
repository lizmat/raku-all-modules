use v6.c;

class Game::Sudoku:ver<1.0.0>:auth<simon.proctor@gmail.com> {

    subset GridCode of Str where * ~~ /^ <[0..9]> ** 81 $/;
    subset Idx of Int where 0 <= * <= 8;
    subset CellValue of Int where 0 <= * <= 9;

    has @!grid;
    has $!initial;
    has $!valid-all;
    has $!complete-all;
    has $!none-all;
    
    multi submethod BUILD( GridCode :$code = ("0" x 81) ) {
        my @tmp = $code.comb.map( *.Int );
        my @initial-list = ();
        (^9 X ^9).map(
            -> ($x,$y) {
                @!grid[$y][$x] = @tmp[($y*9)+$x];
                @initial-list.push( "$x,$y" ) if @tmp[($y*9)+$x] > 0;
            }
        );
        $!initial = set( @initial-list );

        $!valid-all = all(
            (^9).map(
                {
                    |(
                        one( none( self.row( $_ ).map( -> ( $x, $y ) { @!grid[$y][$x] } ) ),
                             one( self.row( $_ ).map( -> ( $x, $y ) { @!grid[$y][$x] } ) ) ),
                        one( none( self.col( $_ ).map( -> ( $x, $y ) { @!grid[$y][$x] } ) ),
                             one( self.col( $_ ).map( -> ( $x, $y ) { @!grid[$y][$x] } ) ) ),
                        one( none( self.square( $_ ).map( -> ( $x, $y ) { @!grid[$y][$x] } ) ),
                             one( self.square( $_ ).map( -> ( $x, $y ) { @!grid[$y][$x] } ) ) )
                    )
                }
            )
        );
        $!complete-all = all(
            (^9).map(
                {
                    |(
                        one( self.row( $_ ).map( -> ( $x, $y ) { @!grid[$y][$x] } ) ),
                        one( self.col( $_ ).map( -> ( $x, $y ) { @!grid[$y][$x] } ) ),
                        one( self.square( $_ ).map( -> ( $x, $y ) { @!grid[$y][$x] } ) )
                    )
                }
            )
        );
        $!none-all = none( (^9 X ^9).map( -> ($x,$y) { @!grid[$y][$x] } ) );
    }

    multi method Str {
        return @!grid.map( -> @row { @row.join() } ).join();
    }

    multi method gist {
        my @lines;
        for ^9 -> $y {
            my @row;
            for ^9 -> $x {
                @row.push( @!grid[$y][$x] > 0 ?? @!grid[$y][$x] !! ' ' );
                @row.push( "|" ) if $x == 2|5;
            }
            @lines.push( @row.join() );
            @lines.push( "---+---+---" ) if $y == 2|5;
        }
        return @lines.join( "\n" );
    }

    method valid {
        [&&] (1..9).map( so $!valid-all == * );
    }

    method complete {
        [&&] (1..9).map( so $!complete-all == *  );
    }

    method full {
        so $!none-all == 0;
    }

    method row( Idx $y ) {
        return (^9).map( { ( $_, $y ) } );
    }

    method col( Idx $x ) {
        return (^9).map( { ( $x, $_ ) } );
    }

    multi method square( Idx $sq ) {
        my $x = $sq % 3 * 3;
        my $y = $sq div 3 * 3;
        return self.square( $x, $y );
    }

    multi method square( Idx $x, Idx $y ) {
        my $tx = $x div 3 * 3;
        my $ty = $y div 3 * 3;
        return ( (0,1,2) X (0,1,2) ).map( -> ( $dx, $dy ) { ( $tx + $dx, $ty + $dy ) } );
    }

    method possible( Idx $x, Idx $y ) {
        return () if @!grid[$y][$x] > 0;

        ( (1..9) (-) set(
              ( self.row($y).map( -> ( $x, $y ) { @!grid[$y][$x] } ).grep( * > 0 ) ),
              ( self.col($x).map( -> ( $x, $y ) { @!grid[$y][$x] } ).grep( * > 0 ) ),
              ( self.square($x,$y).map( -> ( $x, $y ) { @!grid[$y][$x] } ).grep( * > 0 ) )
          ) ).keys.sort;
    }

    multi method cell( Idx $x, Idx $y ) {
        @!grid[$y][$x] ?? @!grid[$y][$x] !! Nil;
    }

    multi method cell( Idx $x, Idx $y, CellValue $val ) {
        return self if $!initial{"$x,$y"};
        @!grid[$y][$x] = $val;
        return self;
    }

}

=begin pod

=head1 NAME

Game::Sudoku - Store, validate and solve sudoku puzzles

=head1 SYNOPSIS

    use Game::Sudoku;

    # Create an empty game
    my $game = Game::Sudoku.new();
    # Set some cells
    $game.cell(0,0,1).cell(0,1,2);
    # Test the results
    $game.valid();
    $game.full();
    $game.complete();
    
    # Get possible values for a cell
    $game.possible(0,2);

=head1 DESCRIPTION

Game::Sudoku is a simple library to store, test and attempt to solve sudoku puzzles.

Currently the libray can be used as a basis for doing puzzles and can solve a number of them.
I hope to add additional functionality to it in the future.

The Game::Sudoku::Solver module includes documenation for using the solver.

=head1 METHODS

=head2 new( Str :code -> Game::Sudoku )

The default constructor will accept and 81 character long string comprising of combinations of 0-9.
This code can be got from an existing Game::Sudoku object by calling it's .Str method.

=head2 valid( -> Bool )

Returns True if the sudoku game is potentially valid, IE noe row, colum or square has 2 of any number. A valid puzzle may not be complete.

=head2 full( -> Bool )

Returns True if the sudoku game has all it's cells set to a non zero value. Note that the game may not be valid.

=head2 complete( -> Bool )

Returns True is the sudoku game is both valid and full.

=head2 possible( Int, Int -> List )

Returns the List of numbers that can be put in the current cell. Note this performs a simple check of the row, column and square the cell is in it does not perform more complex logical checks.

Returns an empty List if the cell already has a value set or if there are no possible values.

=head2 cell( Int, Int -> Int )
=head2 cell( Int, Int, Int -> Game::Sudoku )

Getter / Setter for individual cells. The setter returns the updated game allowing for method chaining.
Note that attempting to set a value defined in the constructor will not work, returning the unchanged
game object.

=head2 row( Int -> List(List) )

Returns the list of (x,y) co-ordinates in the given row. 

=head2 col( Int -> List(List) )

Returns the list of (x,y) co-ordinates in the given column. 

=head2 square( Int -> List(List) )
=head2 square( Int, Int -> List(List) )

Returns the list of (x,y) co-ordinates in the given square of the grid. A square can either be references by a cell within it or by it's index.

    0|1|2
    -----
    3|4|5
    -----
    6|7|8

=head1 AUTHOR

Simon Proctor <simon.proctor@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2017 Simon Proctor

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
