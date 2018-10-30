#!/usr/bin/env perl6

use v6;

use lib 'lib';
use NativeCall;
use Graphics::PLplot::Raw;

#
# 3D line and point plot demo.
#
# Original C code is found at http://plplot.sourceforge.net/examples.php?demo=18
#
# Does a series of 3-d plots for a given data set, with different
# viewing options in each plot.
#

my @opt = 1, 0, 1, 0;
my @alt = 20.0, 35.0, 50.0, 65.0;
my @az  = 30.0, 40.0, 50.0, 60.0;

sub MAIN {
    constant NPTS = 1000;

    # Set Output device
    plsdev("wxwidgets");

    # Initialize plplot
    plinit;

    for ^4 -> $k {
        test-poly($k);
    }

    my $x = CArray[num64].new;
    my $y = CArray[num64].new;
    my $z = CArray[num64].new;

    # From the mind of a sick and twisted physicist...
    for 0..^NPTS -> $i {
        $z[$i] = (-1.0 + 2.0 * $i / NPTS).Num;
    
        # Pick one ...
        my $r = $z[$i];

        $x[$i] = ($r * cos(2.0 * pi * 6.0 * $i / NPTS)).Num;
        $y[$i] = ($r * sin(2.0 * pi * 6.0 * $i / NPTS)).Num;
    }
    for ^4 -> $k {
        pladv(0);
        plvpor(0.0.Num, 1.0.Num, 0.0.Num, 0.9.Num);
        plwind(-1.0.Num, 1.0.Num, -0.9.Num, 1.1.Num);
        plcol0(1);
        plw3d(1.0.Num, 1.0.Num, 1.0.Num, -1.0.Num, 1.0.Num, -1.0.Num, 1.0.Num, -1.0.Num, 1.0.Num, @alt[$k].Num, @az[$k].Num);
        plbox3("bnstu", "x axis", 0.0.Num, 0,
            "bnstu", "y axis", 0.0.Num, 0,
            "bcdmnstuv", "z axis", 0.0.Num, 0);

        plcol0(2);

        if (@opt[$k]) {
            plline3(NPTS, $x, $y, $z);
        }
        else {
            # U+22C5 DOT OPERATOR.
            plstring3(NPTS, $x, $y, $z, "⋅");
        }

        plcol0(3);
        my $title = sprintf("#frPLplot Example 18 - Alt=%.0f, Az=%.0f",
            @alt[$k], @az[$k]);
        plmtex("t", 1.0.Num, 0.5.Num, 0.5.Num, $title);
    }

    # Cleanup
    plend;
}

sub test-poly($k) {
    my @draw = (1, 1, 1, 1),
               ( 1, 0, 1, 0 ),
               ( 0, 1, 0, 1 ),
               ( 1, 1, 0, 0 );

    pladv(0);
    plvpor(0.0.Num, 1.0.Num, 0.0.Num, 0.9.Num);
    plwind(-1.0.Num, 1.0.Num, -0.9.Num, 1.1.Num);
    plcol0(1);
    plw3d(1.0.Num, 1.0.Num, 1.0.Num, -1.0.Num, 1.0.Num, -1.0.Num, 1.0.Num, -1.0.Num, 1.0.Num, @alt[$k].Num, @az[$k].Num);
    plbox3("bnstu", "x axis", 0.0.Num, 0,
        "bnstu", "y axis", 0.0.Num, 0,
        "bcdmnstuv", "z axis", 0.0.Num, 0);

    my $x = CArray[num64].new;
    my $y = CArray[num64].new;
    my $z = CArray[num64].new;

    plcol0(2);

    my sub THETA($a) {
        2.0 * pi * ($a) / 20.0
    }

    my sub PHI($a) {
        pi * ($a) / 20.1
    }

    for ^20 -> $i {
        for ^20 -> $j {
            $x[0] = sin(PHI($j)) * cos(THETA($i));
            $y[0] = sin(PHI($j)) * sin(THETA($i));
            $z[0] = cos(PHI($j));

            $x[1] = sin(PHI($j + 1)) * cos(THETA($i));
            $y[1] = sin(PHI($j + 1)) * sin(THETA($i));
            $z[1] = cos(PHI($j + 1));

            $x[2] = sin(PHI($j + 1)) * cos(THETA($i + 1));
            $y[2] = sin(PHI($j + 1)) * sin(THETA($i + 1));
            $z[2] = cos(PHI($j + 1));

            $x[3] = sin(PHI($j)) * cos(THETA($i + 1));
            $y[3] = sin(PHI($j)) * sin(THETA($i + 1));
            $z[3] = cos(PHI($j));

            $x[4] = sin(PHI($j)) * cos(THETA($i));
            $y[4] = sin(PHI($j)) * sin(THETA($i));
            $z[4] = cos(PHI($j));

            my $draw = CArray[int32].new;
            for 0..3 -> $o {
                $draw[$o] = @draw[$k][$o];
            }
            plpoly3(5, $x, $y, $z, $draw, 1);
        }
    }

    plcol0(3);
    plmtex("t", 1.0.Num, 0.5.Num, 0.5.Num, "unit radius sphere");
}
