#!/usr/bin/env perl6

BEGIN { @*INC.push('../lib') };

use Imlib2;

my $number_of_sides = 5;
my $width = 200;
my $height = 200;
my $radius = 100;
my $xc = 100;
my $yc = 100;
my $rotation = 45;

my $angle = $rotation * pi / 180;

my $im = Imlib2.new();
my $newimage = $im.create_image($width, $height);
exit() unless $newimage;

$newimage.context_set();

$im.image_draw_rectangle(
	location => (0, 0),
	size     => (200, 200),
	fill     => True);

my $polygon = $im.polygon_new();
exit() unless $polygon;

my $x = $radius * cos(0);
my $y = $radius * sin(0);

($x, $y) = rotate_point($angle, $x, $y) if $angle;
$polygon.add_point(($xc + $x).Int, ($yc + $y).Int);
	
loop (my $i = 1; $i < $number_of_sides; $i++) {

	my $x = $radius * cos($i * 2 * pi / $number_of_sides);
	my $y = $radius * sin($i * 2 * pi / $number_of_sides);

	($x, $y) = rotate_point($angle, $x, $y) if $angle;

	$polygon.add_point(($xc + $x).Int, ($yc + $y).Int);
}

$im.context_set_color(0xff0000ff);
$im.image_draw_polygon($polygon);

$polygon.free();

$im.context_set_color("#000000");
$im.image_draw_circumference(
	center => (100, 100),
	radius => 100
);

$im.image_set_format("png");
unlink("images/test_regular_polygon.png") if "images/test_regular_polygon.png".IO ~~ :e;
$im.save_image("images/test_regular_polygon.png");
$im.free_image();

exit();


sub rotate_point($angle, $x, $y) {
	my $xnew = cos($angle) * $x - sin($angle) * $y;
	my $ynew = sin($angle) * $x + cos($angle) * $y;
	return ($xnew, $ynew);
}
