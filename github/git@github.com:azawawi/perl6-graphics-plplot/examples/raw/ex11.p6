#!/usr/bin/env perl6

use v6;

use lib 'lib';
use NativeCall;
use Graphics::PLplot::Raw;

#
# Mesh plot demo.
#
# Original C code is found at http://plplot.sourceforge.net/examples.php?demo=11
#
# Does a series of mesh plots for a given data set, with different viewing
# options in each plot.
#


constant XPTS   = 35;            # Data points in x
constant YPTS   = 46;            # Data points in y
constant LEVELS = 10;

my @opt = DRAW_LINEXY, DRAW_LINEXY;
my @alt = 33.0, 17.0;
my @az  = 24.0, 115.0;

my @title =
    "#frPLplot Example 11 - Alt=33, Az=24, Opt=3",
    "#frPLplot Example 11 - Alt=17, Az=115, Opt=3";

sub cmap1-init {
    my $i = CArray[num64].new;
    $i[0] = 0.0.Num;         # left boundary
    $i[1] = 1.0.Num;         # right boundary

    my $h = CArray[num64].new;
    $h[0] = 240.Num;         # blue -> green -> yellow ->
    $h[1] = 0.Num;           # -> red

    my $l = CArray[num64].new;
    $l[0] = 0.6.Num;
    $l[1] = 0.6.Num;

    my $s = CArray[num64].new;
    $s[0] = 0.8.Num;
    $s[1] = 0.8.Num;

    plscmap1n(256);
    plscmap1l(0, 2, $i, $h, $l, $s, CArray[int32].new);
}

sub MAIN {

    # Set Output device
    plsdev("wxwidgets");

    # Initialize plplot
    plinit;

    my $x = CArray[num64].new;
    for ^XPTS -> $i {
        $x[$i] = 3.0 * ($i - (XPTS / 2)).Num / (XPTS / 2).Num;
    }

    my $y = CArray[num64].new;
    for ^YPTS -> $i {
        $y[$i] = 3.0 * ($i - (YPTS / 2)).Num / (YPTS / 2).Num;
    }

    my ($zmin, $zmax) = (Inf, -Inf);
    my $z = CArray[CArray[num64]].new;
    for ^XPTS -> $i {
        my $xx = $x[$i];
        $z[$i] = CArray[num64].new;
        for ^YPTS -> $j {
            my $yy = $y[$j];
            $z[$i][$j] = my $zz = 3.0 * (1.0 - $xx) * (1.0 - $xx)
                * exp(-($xx * $xx) - ($yy + 1.0) * ($yy + 1.0))
                - 10.0 * ($xx / 5.0 - ($xx ** 3.0) - ($yy ** 5.0))
                * exp(-$xx * $xx - $yy * $yy) - 1.0 / 3.0
                * exp(-($xx + 1) * ($xx + 1) - ($yy * $yy));
            if $zmin > $zz {
                $zmin = $zz;
            }
            if $zmax < $zz {
                $zmax = $zz;
            }
        }
    }

    my $step = ($zmax - $zmin) / (LEVELS + 1);
    my $clevel = CArray[num64].new;
    for ^LEVELS -> $i {
        $clevel[$i] = $zmin + $step + $step * $i;
    }

    cmap1-init;
    for ^2 -> $k {
        for ^4 -> $i {
            pladv(0);
            plcol0(1);
            plvpor(0.0.Num, 1.0.Num, 0.0.Num, 0.9.Num);
            plwind(-1.0.Num, 1.0.Num, -1.0.Num, 1.5.Num);
            plw3d(1.0.Num, 1.0.Num, 1.2.Num, -3.0.Num, 3.0.Num, -3.0.Num,
                3.0.Num, $zmin.Num, $zmax.Num, @alt[$k].Num, @az[$k].Num);
            plbox3(
                "bnstu",     "x axis", 0.0.Num, 0,
                "bnstu",     "y axis", 0.0.Num, 0,
                "bcdmnstuv", "z axis", 0.0.Num, 4
            );

            plcol0(2);

            if $i == 0 {
                # wireframe plot
                plmesh($x, $y, $z, XPTS, YPTS, @opt[$k]);
            } elsif $i == 1 {
                # magnitude colored wireframe plot
                plmesh($x, $y, $z, XPTS, YPTS, @opt[$k] +| MAG_COLOR);
            } elsif $i == 2 {
                # magnitude colored wireframe plot with sides
                plot3d($x, $y, $z, XPTS, YPTS, @opt[$k] +| MAG_COLOR, 1);
            } elsif $i == 3 {
                # magnitude colored wireframe plot with base contour
                plmeshc($x, $y, $z, XPTS, YPTS, @opt[$k] +| MAG_COLOR +|
                    BASE_CONT, $clevel, LEVELS);
            }

            plcol0(3);
            plmtex("t", 1.0.Num, 0.5.Num, 0.5.Num, @title[$k]);
            say "$i";
        }
    }

    # Clean up
    plend;
}
