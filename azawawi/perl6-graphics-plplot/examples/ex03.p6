#!/usr/bin/env perl6

#
# Polar plot demo.
# Original C example: http://plplot.sourceforge.net/examples.php?demo=03
#
# Generates a polar plot, with a one-to-one scaling.
#

use v6;
use lib 'lib';
use Graphics::PLplot;

if Graphics::PLplot.new(
    device    => "png",
    file-name => "ex03.png"
) -> $plot  {

    # Set orientation to portrait
    # Please note that not all the device drivers support this feature (e.g.
    # some interactive drivers)
    $plot.orientation(1);

    my $dtr = pi / 180.0;
    my @x0;
    my @y0;
    for 0..360 -> $i {
        @x0.push: cos( $dtr * $i );
        @y0.push: sin( $dtr * $i );
    }

    # Begin plotting
    $plot.begin;

    # Set up viewport and window, but do not draw box
    $plot.environment(
        x-range => [-1.3, 1.3],
        y-range => [-1.3, 1.3],
        just    => 1,
        axis    => -2,
    );

    # Draw circles for polar grid
    for 0..10 -> $i {
        $plot.arc(
            center     => [0.0, 0.0],
            semi-major => 0.1 * $i,
            semi-minor => 0.1 * $i,
            angle1     => 0.0,
            angle2     => 360.0,
            rotate     => 0.0,
            fill       => False,
        );
    }

    $plot.color-index0( 2 );

    for 0..11 -> $i {
        my $theta = 30.0 * $i;
        my $dx    = cos( $dtr * $theta );
        my $dy    = sin( $dtr * $theta );

        # Draw radial spokes for polar grid
        $plot.join( Num(0.0), Num(0.0), $dx, $dy );
        my $text = sprintf( "%d", $theta.round );

        # Write labels for angle
        my $offset;
        if $theta < 9.99 {
            $offset = 0.45;
        } elsif $theta < 99.9 {
            $offset = 0.30;
        } else {
            $offset = 0.15;
        }

        # Slightly off zero to avoid floating point logic flips at 90 and 270 deg.
        if ( $dx >= -0.00001 ) {
            $plot.text(
                point       => [$dx, $dy],
                inclination => [$dx, $dy],
                just        => -$offset,
                text        => $text);
        } else {
            $plot.text(
                point       => [$dx, $dy],
                inclination => [-$dx, -$dy],
                just        => 1.0 + $offset,
                text        => $text);
        }
    }

    # Draw the graph
    my @points;
    for 0..360 -> $i {
        my $r = sin( $dtr * ( 5 * $i ) );
        my $x = @x0[$i] * $r;
        my $y = @y0[$i] * $r;
        @points.push( ($x, $y) );
    }
    $plot.color-index0( 3 );
    $plot.line( @points );

    $plot.color-index0( 4 );
    $plot.text-viewport(
        side => "t",
        disp => 2.0,
        pos  => 0.5,
        just => 0.5,
        text => "#frPLplot Example 3 - r(#gh)=sin 5#gh" );

    LEAVE {
        $plot.end;
    }
}
