BEGIN { @*INC.unshift('t') }
use GD::Raw;
use gdtest;
use Test;

plan 1;

my $im = gdImageCreate(100, 100) or die;
my $white = gdImageColorAllocate($im, 0xff, 0xff, 0xff);
my $black = gdImageColorAllocate($im, 0, 0, 0);
gdImageFilledRectangle($im, 0, 0, 99, 99, $white);
my @points;
@points[$_] = gdPointPtr.new for ^3;
@points[0].x = 10;
@points[0].y = 10;
@points[1].x = 50;
@points[1].y = 70;
@points[2].x = 90;
@points[2].y = 30;
gdImageFilledPolygon($im, @points, 3, $black);
ok gdAssertImageEqualsToFile("t/ported-gdimagefilledpolygon/gdimagefilledpolygon3.png", $im);
gdImageDestroy($im);
