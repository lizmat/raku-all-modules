BEGIN { @*INC.unshift('t') }
use GD::Raw;
use gdtest;
use Test;

plan 1;

my $im = gdImageCreate(100, 100);
die "gdImageCreate" unless $im;
LEAVE { gdImageDestroy($im) }

my $white = gdImageColorAllocate($im, 0xff, 0xff, 0xff);
my $black = gdImageColorAllocate($im, 0, 0, 0);
gdImageFilledRectangle($im, 0, 0, 99, 99, $white);

my @points;
@points[0] = gdPointPtr.new;
@points[0].x = 10;
@points[0].y = 10;
gdImagePolygon($im, @points, 1, $black);
ok gdAssertImageEqualsToFile("t/ported-gdimagepolygon/gdimagepolygon1.png", $im);

done;
