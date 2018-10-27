#!/usr/bin/env perl6

#
# Simple demo of a 2D line plot.
# Original C example: http://plplot.sourceforge.net/examples.php?demo=00
#
use v6;

use lib 'lib';
use Graphics::PLplot::Raw;
use NativeCall;

# Set Output device
plsdev("wxwidgets");

# Initialize plplot
plinit;

# Create a labeled box to hold the plot.
my ($xmin, $xmax, $ymin, $ymax) = (0.0, 1.0, 0.0, 100);
plenv($xmin.Num, $xmax.Num, $ymin.Num, $ymax.Num, 0, 0);
pllab("x", "y=100 x#u2#d", "Simple PLplot demo of a 2D line plot");

# Prepare data to be plotted.
my $x = CArray[num64].new;
my $y = CArray[num64].new;
constant NSIZE = 101;
for 0..NSIZE -> $i {
    $x[$i] = Num($i) / (NSIZE - 1);
    $y[$i] = Num($ymax * $x[$i] * $x[$i]);
}

# Plot the data that was prepared above.
plline(NSIZE, $x, $y);

# Close PLplot library
plend;
