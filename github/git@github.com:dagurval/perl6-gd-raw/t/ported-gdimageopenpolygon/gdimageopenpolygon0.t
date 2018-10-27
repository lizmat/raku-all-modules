use GD::Raw;
use lib <t>;
use gdtest;
use Test;

plan 1;

my $im = gdImageCreate(100, 100)
    or die;
LEAVE gdImageDestroy($im) if $im;
my $white = gdImageColorAllocate($im, 0xff, 0xff, 0xff);
my $black = gdImageColorAllocate($im, 0, 0, 0);
gdImageFilledRectangle($im, 0, 0, 99, 99, $white);
gdImageOpenPolygon($im, (), 0, $black);  # no effect 
gdImageOpenPolygon($im, (), -1, $black); # no effect
ok gdAssertImageEqualsToFile("t/ported-gdimageopenpolygon/gdimageopenpolygon0.png", $im);
