#!/usr/bin/env perl6

use v6;
use lib 'lib';
use Terminal::Caca;

# Initialize library
given my $o = Terminal::Caca.new {

    # Set the window title
    .title("3D Cube Animation");

    sub to_2d($x, $y, $z) {
        constant D = 5;
        my $px = $x * D / ( D + $z );
        my $py = $y * D / ( D + $z );
        $px, $py
    }

    sub rotate3d-x($x, $y, $z, $angle) {
        my $radians   = $angle * pi / 180.0;
        my $sin-theta = sin($radians);
        my $cos-theta = cos($radians);
        my $rx        = $x;
        my $ry        = $y * $cos-theta - $z * $sin-theta;
        my $rz        = $y * $sin-theta + $z * $cos-theta;
        $rx, $ry, $rz;
    }

    sub rotate3d-y($x, $y, $z, $angle) {
        my $radians   = $angle * pi / 180.0;
        my $sin-theta = sin($radians);
        my $cos-theta = cos($radians);
        my $rx        = $x * $cos-theta - $z * $sin-theta;
        my $ry        = $y;
        my $rz        = $x * $sin-theta + $z * $cos-theta;
        $rx, $ry, $rz;
    }

    sub rotate3d-z($x, $y, $z, $angle) {
        my $radians   = $angle * pi / 180.0;
        my $sin-theta = sin($radians);
        my $cos-theta = cos($radians);
        my $rx        = $x * $cos-theta - $y * $sin-theta;
        my $ry        = $x * $sin-theta + $y * $cos-theta;
        my $rz        = $z;
        $rx, $ry, $rz;
    }

    sub transform-vertex(@vertex, $angle) {
        my $x         = @vertex[0];
        my $y         = @vertex[1];
        my $z         = @vertex[2];
        ($x, $y, $z)  = rotate3d-x($x, $y, $z, $angle);
        ($x, $y, $z)  = rotate3d-y($x, $y, $z, $angle);
        ($x, $y, $z)  = rotate3d-z($x, $y, $z, $angle);
        my ($px, $py) = to_2d($x, $y, $z);
        $px           = $px * 15 + 40;
        $py           = $py * 7 + 15;
        $px, $py, $z
    }

    my @triangles =
     ( (-1.0,-1.0,-1.0),   (-1.0, -1.0,  1.0), (-1.0,  1.0,  1.0) ),
     ( (1.0,  1.0, -1.0),  (-1.0, -1.0, -1.0), (-1.0,  1.0, -1.0) ),
     ( (1.0, -1.0,  1.0),  (-1.0, -1.0, -1.0), (1.0, -1.0, -1.0)  ),
     ( (1.0,  1.0, -1.0),  (1.0, -1.0, -1.0),  (-1.0, -1.0, -1.0) ),
     ( (-1.0, -1.0, -1.0), (-1.0,  1.0,  1.0), (-1.0,  1.0, -1.0) ),
     ( (1.0, -1.0,  1.0),  (-1.0, -1.0,  1.0), (-1.0, -1.0, -1.0) ),
     ( (-1.0,  1.0,  1.0), (-1.0, -1.0,  1.0), (1.0, -1.0,  1.0)  ),
     ( (1.0,  1.0,  1.0),  (1.0, -1.0, -1.0),  (1.0,  1.0, -1.0)  ),
     ( (1.0, -1.0, -1.0),  (1.0,  1.0,  1.0),  (1.0, -1.0,  1.0)  ),
     ( (1.0,  1.0,  1.0),  (1.0,  1.0, -1.0),  (-1.0,  1.0, -1.0) ),
     ( (1.0,  1.0,  1.0),  (-1.0,  1.0, -1.0), (-1.0,  1.0,  1.0) ),
     ( (1.0,  1.0,  1.0),  (-1.0,  1.0,  1.0), (1.0,-1.0, 1.0) );

     # Initialize random face colors
     my @colors;
     for 0..15 -> $color-index {
         my @color = 15, 0, $color-index, 0;
         @colors.push(@color);
     }

    for ^359*10 -> $angle {
        .color(white, white);
        .clear;

        .title(sprintf("Cube Animation, angle: %s", $angle % 360));

        # Transform 3D into 2D and rotate for all icosphere faces
        my @faces-z;
        for @triangles -> @triangle {
            state $face-index = 0;
            my @points;
            my @z-points;
            my $sum-z = 0;
            for @triangle -> @point {
                my ($px, $py, $z) = transform-vertex(@point, $angle);
                @points.push( ($px.Int, $py.Int ));
                $sum-z += $z;
            }

            # Calculate average z value for all triangle points
            my $avg-z = $sum-z / @points.elems;

            @faces-z.push: %(
                face     => @triangle,
                color    => @colors[$face-index],
                points   => @points,
                avg-z    => $avg-z,
            );
            $face-index++;
        }

        # Sort by z to draw farthest first
        @faces-z = @faces-z.sort( { %^a<avg-z> <=> %^b<avg-z> } ).reverse;

        # Draw all faces
        for @faces-z -> %rec {
            state $face-index = 0;
            my @points        = @( %rec<points> );
            my @color         = @( @colors[$face-index % @colors.elems] );

            # Draw filled triangle
            .color(@color[0], @color[1], @color[2], @color[3],
                @color[0], @color[1], @color[2], @color[3]);
            .fill-triangle(
                @points[0][0],@points[0][1],
                @points[1][0],@points[1][1],
                @points[2][0],@points[2][1],
            );
            .color(black, black);
            .thin-triangle(
                 @points[0][0],@points[0][1],
                 @points[1][0],@points[1][1],
                 @points[2][0],@points[2][1],
            );

            $face-index++;
        }

        .refresh;
    }

    # Cleanup on scope exit
    LEAVE {
        .cleanup;
    }

}
