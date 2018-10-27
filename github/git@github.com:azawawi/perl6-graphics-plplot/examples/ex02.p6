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
use Graphics::PLplot;

sub MAIN {
    if Graphics::PLplot.new(device => 'wxwidgets') -> $plot {
        # Initialize plplot
        $plot.begin;

        # Run demos
        demo1($plot);
        demo2($plot);

        LEAVE {
            # Cleanup
            $plot.end;
        }
    }
}

#
# Draws a set of numbered boxes with colors according to cmap0 entry.
#
sub draw-windows($plot, Int $nw, Int $cmap0-offset)
{
    $plot.character-size(
        default => 0.0,
        scale   => 3.5
    );
    # Script font
    $plot.font(4);

    for 0..^$nw -> $i {
        $plot.color-index0($i + $cmap0-offset);
        my $text = sprintf("%d", $i);
        $plot.subpage(0);
        my ($vmin, $vmax) = (0.1, 0.9);
        for 0..2 -> $j {
            $plot.pen-width($j + 1);
            $plot.subpage-viewport($vmin, $vmax, $vmin, $vmax);
            $plot.window(0.0, 1.0, 0.0, 1.0);
            $plot.box("bc", 0.0, 0, "bc", 0.0, 0);
            $vmin += 0.1;
            $vmax -= 0.1;
        }
        $plot.pen-width(1);
        $plot.text(
            point       => (0.5, 0.5),
            inclination => (1.0, 0.0),
            just        => 0.5,
            text        => $text
        );
    }
}


#
# Demonstrates multiple windows and default color map 0 palette.
#
sub demo1($plot) {
    $plot.new-page;

    # Divide screen into 16 regions
    $plot.number-of-subpages(4, 4);

    draw-windows($plot, 16, 0);

    $plot.clear-or-eject-page;
}

#
# Demonstrates multiple windows, user-modified color map 0 palette, and HLS ->
# RGB translation.
#
sub demo2($plot) {
    # Set up cmap0 using 100 custom colors in addition to base 16 (116 total)
    my @rgb;

    # Min & max lightness values
    my ($lmin, $lmax) = (0.15, 0.85);

    $plot.new-page;

    # Divide screen into 100 regions
    $plot.number-of-subpages(10, 10);

    for 0..99 -> $i {
        #
        # Bounds on HLS:
        # hue           [0.0, 360.0]  degrees
        # lightness     [0.0, 1.0]    magnitude
        # saturation    [0.0, 1.0]    magnitude
        #

        # Vary hue uniformly from left to right
        my $h = ((360.0 / 10.0) * ($i % 10));

        # Vary lightness uniformly from top to bottom, between min & max
        my $l = ($lmin + ($lmax - $lmin) * ($i / 10) / 9.0);

        # Use max saturation
        my $s = 1.0;

        # Convert from HLS to RGB
        my ($red, $green, $blue) = $plot.hls-to-rgb($h, $l, $s);

        # Use 255.001 to avoid close truncation decisions in this example.
        @rgb[$i + 16] = ($red * 255.001).Int, ($green * 255.001).Int,
            ($blue  * 255.001).Int;
    }

    # Load default cmap0 colors into our custom set
    for 0..15 -> $i {
        @rgb[$i] = $plot.color-index0-rgb($i);
    }

    # Now set cmap0 all at once (faster, since fewer driver calls)
    $plot.set-cmap0-rgb-colors(@rgb);

    draw-windows($plot, 100, 16);

    $plot.clear-or-eject-page;
}
