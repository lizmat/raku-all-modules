use GD::Raw;
use lib <t>;
use gdtest;
use Test;

plan 1;

my $im = gdImageCreate(100, 100);
die "gdImageCreate" unless $im;
LEAVE { gdImageDestroy($im) if $im}
my $white = gdImageColorAllocate($im, 0xff, 0xff, 0xff);
my $black = gdImageColorAllocate($im, 0, 0, 0);
gdImageFilledRectangle($im, 0, 0, 99, 99, $white);

my @points;
@points[0] = gdPointPtr.new;
@points[0].x = 10;
@points[0].y = 10;
@points[1] = gdPointPtr.new;
@points[1].x = 50;
@points[1].y = 70;
@points[2] = gdPointPtr.new;
@points[2].x = 90;
@points[2].y = 30;
gdImagePolygon($im, @points, 3, $black);
ok gdAssertImageEqualsToFile("t/ported-gdimagepolygon/gdimagepolygon3.png", $im);
