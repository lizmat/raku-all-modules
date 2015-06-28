BEGIN { @*INC.unshift('t') }
use GD::Raw;
use gdtest;
use Test;

plan 1;

my $im = gdImageCreate(100, 100) or die;
LEAVE { gdImageDestroy($im) if $im }

gdImageColorAllocate($im, 255, 255, 255);
gdImageSetThickness($im, 20);
gdImageFilledEllipse($im, 30, 50, 20, 20, gdImageColorAllocate($im, 0, 0, 0));

my $path = "t/ported-gdimagefilledellipse/bug00191.png";
ok gdAssertImageEqualsToFile($path, $im);
