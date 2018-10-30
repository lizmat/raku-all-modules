use GD::Raw;
use lib <t>;
use gdtest;
use Test;

plan 1;

my $im = gdImageCreateTrueColor(100,100) or die;
LEAVE { gdImageDestroy($im) }
gdImageFilledEllipse($im, 50,50, 70, 90, 0x50FFFFFF);

my $path = "t/ported-gdimagefilledellipse/bug00010_exp.png";
ok gdAssertImageEqualsToFile $path, $im;
