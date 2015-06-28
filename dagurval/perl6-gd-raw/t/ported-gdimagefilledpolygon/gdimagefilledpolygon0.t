BEGIN { @*INC.unshift('t') }
use GD::Raw;
use gdtest;
use Test;

plan 1;

my $im = gdImageCreate(100, 100) or die;
my $white = gdImageColorAllocate($im, 0xff, 0xff, 0xff);
my $black = gdImageColorAllocate($im, 0, 0, 0);
gdImageFilledRectangle($im, 0, 0, 99, 99, $white);
gdImageFilledPolygon($im, (), 0, $black);  # no effect
gdImageFilledPolygon($im, (), -1, $black); # no effect
ok gdAssertImageEqualsToFile("t/ported-gdimagefilledpolygon/gdimagefilledpolygon0.png", $im);
gdImageDestroy($im);
