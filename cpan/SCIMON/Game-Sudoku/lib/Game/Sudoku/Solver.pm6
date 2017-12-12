unit module Game::Sudoku::Solver;

use Game::Sudoku;

sub solve-puzzle( Game::Sudoku $game ) is export {
    return find-solution( Game::Sudoku.new( :code( $game.Str ) ) );
}

sub find-solution( Game::Sudoku $result ) {
    my $initial;
    repeat {
        $initial = $result.perl;
        simple-solutions( $result );
    } while ( ! $result.complete && $result.perl ne $initial );

    return $result if $result.complete;

    my $options = ( (^9 X ^9)
                    .map( -> ($x,$y) { ($x,$y) => $result.possible($x,$y).Array } )
                    .grep( *.value.elems > 0 )
                    .sort( *.value.elems <=> *.value.elems ) )[0];

    return $result unless $options;

    my $cell = $options.key;
    my @possible = $options.value;

    while ( ! $result.complete && @possible.elems > 0 ) {
        my $value = shift @possible;
        my ($x,$y) = $cell;
        my $original = $result.Str;
        $result.cell( $x, $y, $value );
        find-solution( $result );
        $result.reset( :code($original) ) unless $result.complete;
    }

    return $result;
}

sub simple-solutions( Game::Sudoku $result ) {
    find-single-options( $result );

    return $result if $result.complete;

    return find-uniques( $result );
}

sub find-uniques( Game::Sudoku $result ) {
    my @changes;

    for <row col square> -> $method-name {
        my $method = $result.^find_method($method-name);
        for ^9 -> $idx {
            my $only = [(^)] $result.$method($idx).map( -> ( $x,$y ) { $result.possible($x,$y,:set) } );

            for $only.keys -> $val {
                for $result.$method($idx) -> ($x,$y) {
                    if $val (elem) $result.possible($x,$y,:set) {
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

    return $result;
}

sub find-single-options( Game::Sudoku $result ) {
    my @changes;
    repeat {
        @changes = (^9 X ^9)
        .map( -> ($x,$y) { ($x,$y) => $result.possible($x,$y) } )
        .grep( *.value.elems == 1 );

        for @changes -> $p {
            my ( $x, $y ) = $p.key;
            $result.cell($x,$y,$p.value[0]);
        }
    } while ( @changes.elems > 0 && ! $result.complete );

    return $result
}

=begin pod

=head1 NAME

Game::Sudoku::Solver - Attempt to solve Sudoku puzzles

=head1 DESCRIPTION

Game::Sudoku::Solver provides a function that takes a Game::Sudoku puzzle and retuns the puzzle solved to the extent
of it's abilities.

=head1 FUNCTIONS

The following function is exported by default when is module is used.

=head2 solve-puzzle( Game::Sudoku -> Game::Sudoku )

Takes a Game::Sudoku object and attempts to solve it by a series of simple tests looking for unique values. 

Once it's run out of simple solutions it will then try depth first tree solutions on the result. 

=head1 AUTHOR

Simon Proctor <simon.proctor@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2017 Simon Proctor

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
