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

    my @p =
        (0,0,0), # 0
        (1,0,0), # 1
        (1,1,0), # 2
        (0,1,0), # 3
        (0,0,1), # 4
        (1,0,1), # 5
        (1,1,1), # 6
        (0,1,1); # 7

    my @sides =
        ( @p[0], @p[1], @p[2], @p[3], ),
        ( @p[4], @p[5], @p[6], @p[7], ),
        ( @p[5], @p[1], @p[2], @p[6], ),
        ( @p[4], @p[0], @p[3], @p[7], ),
        ( @p[6], @p[2], @p[3], @p[7], ),
        ( @p[4], @p[0], @p[3], @p[7], );

    for ^359 -> $angle {
        .clear;
        for @sides -> @side {
            my @points;
            for @side -> @point {
                my $x         = @point[0] * 2 - 1;
                my $y         = @point[1] * 2 - 1;
                my $z         = @point[2] * 2 - 1;
                ($x, $y, $z)  = rotate3d-x($x, $y, $z, $angle);
                ($x, $y, $z)  = rotate3d-y($x, $y, $z, $angle);
                ($x, $y, $z)  = rotate3d-z($x, $y, $z, $angle);
                my ($px, $py) = to_2d($x, $y, $z);
                $px           = $px * 15 + 40;
                $py           = $py * 7 + 15;
                @points.push( ($px.Int, $py.Int ));
            }
            @points.push( @points[0] );

            # Draw a 3D Cube in 2D space
            .color(white, black);
            .thin-polyline(@points);
            .color(green, black);
            my $i = 0;
            for @points -> $point {
                .text($point[0], $point[1], "" ~ $i++);
            }
        }
        .refresh;
        sleep 0.042 / 2;
    }

    # Cleanup on scope exit
    LEAVE {
        .cleanup;
    }

}
