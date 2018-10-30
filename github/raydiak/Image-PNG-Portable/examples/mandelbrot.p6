#!/usr/bin/env perl6

use v6;

my constant $root = $?FILE.IO.parent.parent;
use lib $root.child('lib');
use lib $root.child('blib').child('lib');

use Image::PNG::Portable;

sub MAIN (
    Int $width = 150,
    Int $height = $width,
    Int :$iter = 150,
    Bool :$quiet = False
) {
    my $img = Image::PNG::Portable.new: :$width, :$height;

    my ($max-x, $max-y) = $width - 1, $height - 1;
    my $half-height = ($height / 2).ceiling;
    my $half-max-y = $half-height - 1 unless $height %% 2;
    my ($r_e, $g_e, $b_e) =
        5 ** e,
        5 ** ((1 + 5.sqrt) / 2), # phi (just cuz)
        5;

    say 'Rendering...' unless $quiet;
    for ^$width X ^$half-height -> ($x, $y) {

        # this knot will go away when initial fill color can be specified
        my $set = False;
        NEXT {
            unless $set {
                $img.set: $x, $y, 255, 255, 255;
                $img.set: $x, $max-y - $y, 255, 255, 255
                    unless $half-max-y && $y == $half-max-y;
            }
        }

        my $c = ($x/$max-x - .5) * 4 + ($y/$max-y - .5) * 4i * $height / $width;
        my ($re, $im) = $c.re, $c.im;

        # https://en.wikipedia.org/wiki/Mandelbrot_set#Cardioid_.2F_bulb_checking
        my $q = ($re - .25) ** 2 + $im ** 2;
        next if $q * ($q + ($re - .25)) < .25 * $im ** 2 ||
            ($re + 1) ** 2 + $im ** 2 < .0625;

        my $z = Complex.new: 0, 0;
        for ^$iter -> $i {
            next if ($z = $z**2 + $c).abs <= 2;

            my $shade = 1 - $i / ($iter - 1);
            my ($r, $g, $b) = 
                (( $shade ** $r_e )*255).round,
                (( $shade ** $g_e )*255).round,
                (( $shade ** $b_e )*255).round;

            $img.set: $x, $y, $r, $g, $b;
            $img.set: $x, $max-y - $y, $r, $g, $b
                unless $half-max-y && $y == $half-max-y;

            $set = True;
            last;
        }
    }

    printf "\%.2fs\n", now - BEGIN { now } unless $quiet;

    $img.write: 'mandelbrot.png';

    True;
}


