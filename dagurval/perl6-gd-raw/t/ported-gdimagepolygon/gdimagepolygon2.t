BEGIN { @*INC.unshift('t') }
use GD::Raw;
use gdtest;
use Test;
use NativeCall;

plan 1;

my $im = gdImageCreate(100, 100);
die "gdImageCreate" unless $im;

my $white = gdImageColorAllocate($im, 0xff, 0xff, 0xff);
my $black = gdImageColorAllocate($im, 0, 0, 0);
gdImageFilledRectangle($im, 0, 0, 99, 99, $white);
my @points;
@points[0] = gdPointPtr.new();
@points[0].x = 10;
@points[0].y = 10;
@points[1] = gdPointPtr.new();
@points[1].x = 50;
@points[1].y = 70;

gdImagePolygon($im, @points, 2, $black);
my $r = gdAssertImageEqualsToFile("t/ported-gdimagepolygon/gdimagepolygon2.png", $im);
gdImageDestroy($im);
ok $r, "gdAssertImageEqualsToFile";

done;
