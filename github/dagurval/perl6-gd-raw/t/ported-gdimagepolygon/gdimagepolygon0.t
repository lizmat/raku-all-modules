use GD::Raw;
use lib <t>;
use gdtest;
use Test;

plan 1;

my $im = gdImageCreate(100, 100);
die "gdIamgeCreate" unless $im;
LEAVE { gdImageDestroy($im); }
my $white = gdImageColorAllocate($im, 0xff, 0xff, 0xff);
my $black = gdImageColorAllocate($im, 0, 0, 0);
gdImageFilledRectangle($im, 0, 0, 99, 99, $white);
gdImagePolygon($im, (), 0, $black); # no effect
gdImagePolygon($im, (), -1, $black); # no effect
ok gdAssertImageEqualsToFile("t/ported-gdimagepolygon/gdimagepolygon0.png", $im);

done-testing;
