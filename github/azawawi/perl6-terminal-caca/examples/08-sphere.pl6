#!/usr/bin/env perl6

use v6;
use lib 'lib';
use Terminal::Caca;

# Initialize library
given my $o = Terminal::Caca.new {

    # Set window title
    .title("Sphere");

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

    sub polar-to-cartesian($r, $ϴ, $Φ) {
        my $x = $r * sin($ϴ) * cos($Φ);
        my $y = $r * cos($ϴ) * sin($Φ);
        my $z = $r * cos($ϴ);
        $x, $y, $z;
    }

    my @vertices;
    my $r = 1;
    my $parallels-count = 5;
    my $meridians-count = 5;
    for ^$parallels-count -> $j {
        my $parallel = pi * ($j + 1) / $parallels-count;
        for ^$meridians-count -> $i {
            my $meridian    = 2.0 * pi * $i / $meridians-count;
            my ($x, $y, $z) = polar-to-cartesian($r, $meridian, $parallel);
            @vertices.push: ($x, $y, $z);
        }
    }

    for ^359 -> $angle {
        .clear;
        
        my @points;
        for @vertices -> @vertex {
            my $x         = @vertex[0];
            my $y         = @vertex[1];
            my $z         = @vertex[2];
            ($x, $y, $z)  = rotate3d-x($x, $y, $z, $angle);
            ($x, $y, $z)  = rotate3d-y($x, $y, $z, $angle);
            ($x, $y, $z)  = rotate3d-z($x, $y, $z, $angle);
            my ($px, $py) = to_2d($x, $y, $z);
            $px           = $px * 15 + 40;
            $py           = $py * 7 + 15;
            @points.push: ($px.Int, $py.Int );
        }
        #@points.push( @points[0] );

        # Draw a 3D Cube in 2D space
        .color(white, black);
        .thin-polyline(@points);
        .color(green, black);
        my $i = 0;
        for @points -> $point {
            #.text($point[0], $point[1], "" ~ $i++);
        }

        .refresh;
        sleep 0.042 / 2;
        #last;
    }

    # Refresh display
    .refresh;

    # Wait for a key press event
    .wait-for-keypress;

    # Cleanup on scope exit
    LEAVE {
        .cleanup;
    }
}
