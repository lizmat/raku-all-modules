#!/usr/bin/env perl6

#
# Multiple window and color map 0 demo.
# Original C code is found at http://plplot.sourceforge.net/examples.php?demo=02
#
# Demonstrates multiple windows and color map 0 palette, both default and
# user-modified.
#

use v6;
use lib 'lib';
use NativeCall;
use Graphics::PLplot::Raw;

sub MAIN {
    # Set Output device
    plsdev("wxwidgets");

    # Initialize plplot
    plinit;

    # Run demos
    demo1;
    demo2;

    plend;
}

#
# Draws a set of numbered boxes with colors according to cmap0 entry.
#
sub draw-windows(Int $nw, Int $cmap0-offset)
{
    plschr(0.0.Num, 3.5.Num);
    plfont(4);

    for 0..^$nw -> $i {
        plcol0($i + $cmap0-offset);
        my $text = sprintf("%d", $i);
        pladv(0);
        my $vmin = 0.1;
        my $vmax = 0.9;
        for 0..2 -> $j {
            plwidth(($j + 1).Num);
            plvpor($vmin.Num, $vmax.Num, $vmin.Num, $vmax.Num);
            plwind(0.0.Num, 1.0.Num, 0.0.Num, 1.0.Num);
            plbox("bc", 0.0.Num, 0, "bc", 0.0.Num, 0);
            $vmin += 0.1;
            $vmax -= 0.1;
        }
        plwidth(1.Num);
        plptex(0.5.Num, 0.5.Num, 1.0.Num, 0.0.Num, 0.5.Num, $text);
    }
}


#
# Demonstrates multiple windows and default color map 0 palette.
#
sub demo1 {
    plbop;

    # Divide screen into 16 regions
    plssub(4, 4);

    draw-windows(16, 0);

    pleop;
}

#
# Demonstrates multiple windows, user-modified color map 0 palette, and HLS ->
# RGB translation.
#
sub demo2 {
    # Set up cmap0
    # Use 100 custom colors in addition to base 16
    my $r = CArray[int32].new;
    my $g = CArray[int32].new;
    my $b = CArray[int32].new;
    $r[115] = 0;
    $g[115] = 0;
    $b[115] = 0;

    # Min & max lightness values
    my ($lmin, $lmax) = (0.15, 0.85);

    plbop;

    # Divide screen into 100 regions
    plssub(10, 10);

    for 0..99 -> $i {
        #
        # Bounds on HLS, from plhlsrgb commentary:
        # hue           [0., 360.]  degrees
        # lightness     [0., 1.]    magnitude
        # saturation    [0., 1.]    magnitude
        #

        # Vary hue uniformly from left to right
        my $h = ((360.0 / 10.0) * ($i % 10)).Num;
        # Vary lightness uniformly from top to bottom, between min & max
        my $l = ($lmin + ($lmax - $lmin) * ($i / 10) / 9.0).Num;
        # Use max saturation
        my $s = 1.0.Num;

        my (num64 $r1, num64 $g1, num64 $b1);
        plhlsrgb($h, $l, $s, $r1, $g1, $b1);

        # Use 255.001 to avoid close truncation decisions in this example.
        $r[$i + 16] = ($r1 * 255.001).Int;
        $g[$i + 16] = ($g1 * 255.001).Int;
        $b[$i + 16] = ($b1 * 255.001).Int;
    }

    # Load default cmap0 colors into our custom set
    for 0..15 -> $i {
        my (int32 $red, int32 $green, int32 $blue);
        plgcol0($i, $red, $green, $blue);
        $r[$i] = $red;
        $g[$i] = $green;
        $b[$i] = $blue;
    }

    # Now set cmap0 all at once (faster, since fewer driver calls)
    plscmap0($r, $g, $b, 116);

    draw-windows(100, 16);

    pleop;
}
