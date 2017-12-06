unit module Game::Sudoku::Solver;

use Game::Sudoku;

sub solve-puzzle( Game::Sudoku $game ) is export {

    my $initial = $game.Str;
    my $result = Game::Sudoku.new( :code($game.Str) );
    my $count;
    repeat {
        $count = [+] (^9 X ^9)
        .map( -> ($x,$y) { ($x,$y) => $result.possible($x,$y) } )
        .grep( *.value.elems == 1 )
        .map( -> $p { my ( $x, $y ) = $p.key; $result.cell($x,$y,$p.value[0]); 1; } );
    } while ( $count > 0 && ! $result.complete );

    return $result if $result.complete;

    my @changes;

    for ^9 -> $idx {
        for <row col square> -> $method-name {
            my $method = $result.^lookup($method-name);
            my $only = [(^)] $result.$method($idx).map( -> ( $x,$y ) { $result.possible($x,$y) } );

            for $only.keys -> $val {
                for $result.$method($idx) -> ($x,$y) {
                    if $val (elem) $result.possible($x,$y) {
                        @changes.push( ($x,$y) => $val );
                    }
                }
            }
        }
    }

    for @changes -> $pair {
        my ( $x, $y ) = $pair.key;
        $result.cell($x,$y,$pair.value[0]);
    }
    if ( ! $result.complete && $result.Str ne $initial ) {
        $result = solve-puzzle($result);
    }

    return $result;
}

=begin pod

=head1 NAME

Game::Sudoku::Solver - Attempt to solve Sudoku puzzles

=head1 DESCRIPTION

Game::Sudoku::Solver provides a function that takes a Game::Sudoku puzzle and retuns the puzzle solved to the extent
of it's abilities.

=head1 FUNCTIONS

The following function is expoted by default when is module is used.

=head2 solve-puzzle( Game::Sudoku -> Game::Sudoku )

Takes a Game::Sudoku object and attempts to solve it by a series of simple tests looking for unique values. 

=head1 AUTHOR

Simon Proctor <simon.proctor@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2017 Simon Proctor

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
