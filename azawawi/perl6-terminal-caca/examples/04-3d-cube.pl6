#!/usr/bin/env perl6

use v6;
use lib 'lib';
use Terminal::Caca;

#TODO finish 3d example with rotation animation fun :)

# Initialize library
given my $o = Terminal::Caca.new {

    # Set the window title
    .title("3D Cube Animation");

    sub to_2d($x, $y, $z) {
        constant D = 10;
        my $px = $x * D / ( D + $z );
        my $py = $y * D / ( D + $z );
        $px, $py
    }

    my @sides = (
        (
            (0,0,0),
            (1,0,0),
            (1,1,0),
            (0,1,0),
        ),
        ( 
            (0,0,1),
            (1,0,1),
            (1,1,1),
            (0,1,1)
        ),
    );

    for @sides -> @side {
        my @points;
        for @side -> @point {
            my ($px, $py) = to_2d(@point[0] * 5, @point[1] * 5, @point[2] * 5);
            $px = $px * 10 + 10;
            $py = $py * 5 + 5;
            @points.push( ($px.Int, $py.Int ));
        }
        @points.push( @points[0] );
        say @points;

        # Draw a 3D Cube in 2D space
        .color(white, black);
        .thin-polyline(@points);
    }

    .refresh;
    .wait-for-keypress;

    # Cleanup on scope exit
    LEAVE {
        .cleanup;
    }

}
