#!/usr/bin/env perl6

#
# Simple demo of a 2D line plot.
# Original C example: http://plplot.sourceforge.net/examples.php?demo=00
#
use v6;

use lib 'lib';
use Graphics::PLplot;

if Graphics::PLplot.new(
    device    => "wxwidgets",
    #file-name => "ex00.png"
) -> $plot  {

    # Begin plotting
    $plot.begin;

    # Create a labeled box to hold the plot.
    my $y-max = 100;
    $plot.environment(
        x-range => [0.0, 1.0],
        y-range => [0.0, $y-max],
        just    => 0,
        axis    => 0,
   );
    $plot.label(
        x-axis => "x",
        y-axis => "y=100 x#u2#d",
        title  => "Simple PLplot demo of a 2D line plot",
   );

    # Prepare data to be plotted.
    constant NSIZE = 101;
    my @points = gather {
        for 0..^NSIZE -> $i {
            my $x = Num($i) / (NSIZE - 1);
            my $y = Num($y-max * $x * $x);
            take ($x, $y);
        }
    };

    # Plot the data that was prepared above.
    $plot.line(@points);

    LEAVE {
        $plot.end;
    }
}
