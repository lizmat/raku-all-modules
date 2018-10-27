#!/usr/bin/env perl6

BEGIN { @*INC.push('../lib') };

use Imlib2;

my $im = Imlib2.new();
# load an image
my $loadedimage = $im.load_image("images/camelia-logo.jpg");
exit() unless $loadedimage;

# Sets the current image Imlib2 will be using with its function calls.
$loadedimage.context_set();

#Creates a new empty color range
my $color_range = $im.create_color_range();

# Sets the current color range to use for rendering gradients.
$color_range.context_set();

# Returns the current color range being used for gradients. 
say "Yes I'm a color range." if $im.context_get_color_range();

$im.context_set_color(
	red   => 255,
	green => 0,
	blue  => 0,
	alpha => 255
);

# Adds the current color to the current color range at a distance_away
# distance from the previous color in the range.
$im.add_color_to_color_range(0);

# Another way to set color, alpha is optional.
$im.context_set_color(0x0000ffff);
$im.add_color_to_color_range(1);

$im.context_set_color(
	red   => 0,
	green => 255,
	blue  => 0,
	alpha => 127
);
$im.add_color_to_color_range(2);

#
# Draw rectangles w/ RGBA gradient
#
$im.image_draw_rectangle(
	location => (10, 10),
	size     => (240, 50),
	fill     => True,
	gradient => True,
	angle    => -90.0);

#
# Draw rectangle w/ HSVA gradient
#
$im.image_draw_rectangle(
	location => (10, 70),
	size     => (240, 50),
	fill     => True,
	gradient => True,
	angle  => 45.0,
	hsva   => True);

# Frees the current color range.
$im.free_color_range();

$im.image_set_format("png");
unlink("images/test_color_range.png") if "images/test_color_range.png".IO ~~ :e;
$im.save_image("images/test_color_range.png");
$im.free_image();

exit();
