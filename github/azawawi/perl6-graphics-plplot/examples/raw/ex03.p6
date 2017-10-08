#!/usr/bin/env perl6

#
# Polar plot demo.
# Original C example: http://plplot.sourceforge.net/examples.php?demo=03
#
# Generates a polar plot, with a one-to-one scaling.
#

use v6;
use lib 'lib';
use NativeCall;
use Graphics::PLplot::Raw;

# Set Output device
plsdev("wxwidgets");

# Set orientation to portrait - note not all device drivers
# support this, in particular most interactive drivers do not
plsori(1);

my $dtr = pi / 180.0;
my @x0;
my @y0;
for 0..360 -> $i {
    @x0.push: cos($dtr * $i);
    @y0.push: sin($dtr * $i);
}

# Initialize plplot
plinit;

# Set up viewport and window, but do not draw box
plenv(Num(-1.3), Num(1.3), Num(-1.3), Num(1.3), 1, -2);

# Draw circles for polar grid
for 0..10 -> $i {
    plarc(Num(0.0), Num(0.0), Num(0.1 * $i), Num(0.1 * $i), Num(0.0), Num(360.0), Num(0.0), 0);
}

plcol0(2);

for 0..11 -> $i {
    my $theta = 30.0 * $i;
    my $dx    = cos($dtr * $theta);
    my $dy    = sin($dtr * $theta);

    # Draw radial spokes for polar grid
    pljoin(Num(0.0), Num(0.0), $dx, $dy);
    my $text = sprintf("%d", $theta.round);

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
    if ($dx >= -0.00001) {
        plptex($dx.Num, $dy.Num, $dx.Num, $dy.Num, -$offset.Num, $text);
    } else {
        plptex($dx.Num, $dy.Num, -$dx.Num, -$dy.Num, (1.0 + $offset).Num, $text);
    }
}

# Draw the graph
my $x = CArray[num64].new;
my $y = CArray[num64].new;
for 0..360 -> $i {
    my $r    = sin($dtr * (5 * $i));
    $x[$i] = @x0[$i] * $r;
    $y[$i] = @y0[$i] * $r;
}
plcol0(3);
plline(361, $x, $y);

plcol0(4);
plmtex("t", 2.0.Num, 0.5.Num, 0.5.Num, "#frPLplot Example 3 - r(#gh)=sin 5#gh");

# Close the plot at end
plend;
