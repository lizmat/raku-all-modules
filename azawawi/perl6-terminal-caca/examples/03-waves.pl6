#!/usr/bin/env perl6

use v6;
use lib 'lib';
use Terminal::Caca;

# Initialize library
given my $o = Terminal::Caca.new {

    # Set the window title
    .title("Sine/Cosine Wave Animation");

    # Draw randomly-colored polyline types
    for ^100 -> $i {
        .color(white, black);
        .clear;
        my @sin;
        my @cos;
        constant MAX = 16;
        my $range    = $i % MAX;
        for 0..100 -> $x {
            my $xt      = ($x + $i) * 5;
            my $radians = $xt * pi / 180.0;
            my $y-sin   = Int(sin($radians) * $range + MAX);
            my $y-cos   = Int(cos($radians) * $range + MAX);
            @sin.push( ($x, $y-sin) );
            @cos.push( ($x, $y-cos) )
        }
        .color(white, black);
        .thin-line(0, MAX, 79, MAX);
        .color(light-green, black);
        .thin-polyline(@sin);
        .color(light-red, black);
        .thin-polyline(@cos);
        .refresh;

        sleep 0.125;
    }

    # Cleanup on scope exit
    LEAVE {
        .cleanup;
    }

}
