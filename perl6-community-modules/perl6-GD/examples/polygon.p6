#!/usr/bin/env perl6

BEGIN { @*INC.push('../lib') };

use GD;

my $image = GD::Image.new(300, 300);
exit() unless $image;

my $black = $image.colorAllocate("#000000");
my $white = $image.colorAllocate("#ffffff");
my $red = $image.colorAllocate("#ff0000");
my $green = $image.colorAllocate("#00ff00");
my $blue = $image.colorAllocate("#0000ff");

$image.rectangle(
	location => (0, 0),
	size     => (300, 300),
	fill     => True,
	color    => $white);

$image.rectangle(
	location => (10, 10),
	size     => (100, 100),
	color    => $red);

# triangle

my Int @points = (
10, 20,		# first point
100, 10,	# second point
60, 100);	# third point

my $storage = $image.polygon(
	points => @points,
	open   => False,
	fill   => False,
	color  => $blue);

unlink("images/test_polygon.png") if "images/test_polygon.png".IO ~~ :e;
my $png_fh = $image.open("images/test_polygon.png", "wb");

$image.output($png_fh, GD_PNG);

$png_fh.close;

$image.free($storage);
$image.destroy();

exit();

