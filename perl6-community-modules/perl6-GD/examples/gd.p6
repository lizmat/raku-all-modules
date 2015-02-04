#!/usr/bin/env perl6

BEGIN { @*INC.push('../lib') };

use GD;

my $image = GD::Image.new(200, 200);
exit() unless $image;

my $black = $image.colorAllocate(
	red   => 0,
	green => 0,
	blue  => 0);

my $white = $image.colorAllocate(
	red   => 255,
	green => 255,
	blue  => 255);

my $red = $image.colorAllocate("#ff0000");
my $green = $image.colorAllocate("#00ff00");
my $blue = $image.colorAllocate(0x0000ff);

$image.line(
	start => (0, 0),
	end   => (63, 63),
	color => $white);

$image.rectangle(
	location => (10, 10),
	size     => (100, 100),
	fill     => True,
	color    => $red);

$image.arc(
	center    => (100, 100), # x center, y center
	amplitude => (50, 80),   # width, height
	aperture  => (0, 90),    # start at 0 degrees and stop at 180 degrees
	fill      => True,
	color     => $green);

$image.circumference(
	center   => (100, 100),
	diameter => 200,
	fill     => False,
	color    => $red);

$image.ellipse(
	center => (100, 100),
	axes   => (60, 80),   # width and height
	fill   => False,
	color  => $blue);

my $png_fh = $image.open("test.png", "wb");

$image.output($png_fh, GD_PNG);

$png_fh.close;

$image.destroy();

exit();

