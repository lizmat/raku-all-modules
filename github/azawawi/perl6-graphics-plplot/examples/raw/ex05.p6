#!/usr/bin/env perl6

#
#      Histogram demo.
#
# Original C code is found at http://plplot.sourceforge.net/examples.php?demo=05
#
# Draws a histogram from sample data.
#

use v6;

use lib 'lib';
use NativeCall;
use Graphics::PLplot::Raw;

constant NPTS = 2047;

sub MAIN {

    plsdev("wxwidgets");

    # Initialize plplot
    plinit;

    # Fill up data points
    my $delta = 2.0 * pi / NPTS.Num;
    my $data = CArray[num64].new;
    for ^NPTS -> $i {
        $data[$i] = sin($i * $delta);
    }

    plcol0(1);
    plhist(NPTS, $data, -1.1.Num, 1.1.Num, 44, 0);
    plcol0(2);
    pllab( "#frValue", "#frFrequency",
        "#frPLplot Example 5 - Probability function of Oscillator" );

    plend;
}
