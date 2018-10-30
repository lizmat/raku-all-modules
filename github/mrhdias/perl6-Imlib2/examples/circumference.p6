#!/usr/bin/env perl6

BEGIN { @*INC.push('../lib') };

use Imlib2;

my $im = Imlib2.new();
my $raw_image = $im.create_image(200, 200);
$raw_image.context_set();

my @colors = ("#ff0000", "#00ff00", "#0000ff", "#ffff00", "#ff00ff");

$im.context_set_color("#ffffff");
$im.image_draw_rectangle(
	location => (0, 0),
	size     => (200, 200),
	fill     => True);

my $radius = 64;
my $x = (200/2).Int;
my $y = (200/2).Int;
for @colors -> Str $color {
	$im.context_set_color($color);
	$im.image_draw_circumference(
		center => ($x, $y),
		radius => $radius,
		fill   => True
	);
	$radius = ($radius/2).Int;
}

$im.context_set_color("#000000");
$im.image_draw_circumference(
	center => ($x, $y),
	radius => 64
);

$im.image_set_format("png");
unlink("images/test_circumference.png") if "images/test_circumference.png".IO ~~ :e;
$im.save_image("images/test_circumference.png");

$im.free_image();

exit();
