# Test Geo::Ellipsoid at

use v6;
use Test;

#use Geo::Ellipsoid :constants;
#use Geo::Ellipsoid::Utils :constants;
use Geo::Ellipsoid::Utils;

plan 22;

# This series of tests is for the functions exported from the class.

#===== hms
my @lats =
# ' Nn+' = positive; 'Ss-' = negative
' 10 30',
'N10 30',
'n10 30',
'+10 30',

'S10 30',
's10 30',
'-10 30';
# expected results
my @lats2degs =
'10.5',
'10.5',
'10.5',
'10.5',

'-10.5',
'-10.5',
'-10.5';
my @lons =
# 'Ee+' = positive; ' Ww-' = negative (blank negative!!!!)
'E10 30',
'e10 30',
'+10 30',

' 10 30',
'W10 30',
'w10 30',
'-10 30',
# expected results
my @lons2degs =
'10.5',
'10.5',
'10.5',

'-10.5',
'-10.5',
'-10.5',
'-10.5';
my @hms =
# ' +' = positive; '-' = negative (opposite from NGS function convention above)
' 10 30',
'+10 30',

'-10 30';
# expected results
my @hms2degs =
'10.5',
'10.5',

'-10.5';


# THESE SHOULD BE PROVIDED BY MATH::TRIG BUT THAT FAILS AT THE MOMENT
#===== constants
is $twopi, '6.28318530717959', "twice pi";
is $halfpi, '1.5707963267949', "one-half pi";

#===== sub deg2rad
my @degs = <0 30 45 90 135 180 225 270 315 360 405>;
#----- desired results
my @degs2rads = <
0
0.523598775598299
0.785398163397448
1.5707963267949
2.35619449019234
3.14159265358979
3.92699081698724
4.71238898038469
5.49778714378214
6.28318530717959
7.06858347057703
>;
die "FATAL: list elems not equal" if @degs.elems != @degs2rads.elems;

my $i = 0;
for @degs -> $deg {
    is deg2rad($deg), @degs2rads[$i++], "radians for $deg degrees";
}

#===== sub rad2deg
my @rads = <0 1 2 3 4 5 6 7 8>;
#----- desired results
my @rads2degs = <
0
57.2957795130823
114.591559026165
171.887338539247
229.183118052329
286.478897565412
343.774677078494
401.070456591576
458.366236104659
>;
die "FATAL: list elems not equal" if @rads.elems != @rads2degs.elems;

$i = 0;
for @rads -> $rad {
    is rad2deg($rad), @rads2degs[$i++], "degrees for $rad radians";
}




