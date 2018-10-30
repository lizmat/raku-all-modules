#!/usr/bin/env perl6

BEGIN { @*INC.push('../lib') };

use Imlib2;

my $im = Imlib2.new();
# load an image
my $loadedimage = $im.load_image("images/camelia-logo.jpg");
exit() unless $loadedimage;

# Sets the current image Imlib2 will be using with its function calls.
$loadedimage.context_set();

# Creates an exact duplicate of the current image.
my $clone = $im.clone_image();

# Sets the clone the current image Imlib2 will be using with its
# function calls.
$clone.context_set();

$im.context_set_color(
	red   => 0,
	green => 0,
	blue  => 255,
	alpha => 127
);

$im.image_draw_rectangle(
	location => (10, 10),
	size     => ($im.image_get_width() - 20, $im.image_get_height() - 20));

$im.image_set_format("png");
unlink("images/test_clone.png") if "images/test_clone.png".IO ~~ :e;
$im.save_image("images/test_clone.png");
$im.free_image();

# Sets the original image the current image Imlib2 add free it.
$loadedimage.context_set();
$im.free_image();

exit();
