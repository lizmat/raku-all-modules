#!/usr/bin/env perl6

BEGIN { @*INC.push('../lib') };

use Imlib2;

say "Select a parameter to adjust";
say "[1] - Brightness";
say "[2] - Contrast";
say "[3] - Gamma";
say "[4] - Exit";
my $option = prompt("Please select a parameter to adjust: ");

my $text = "";
given $option {
	when 1 { $text = "-1.0 .. 1.0"; }
	when 2 { $text = "0.0 .. 2.0"; }
	when 3 { $text = "0.5 .. 2.0"; }
	default { exit(); }
}

my $value = prompt("Please select a value between $text: ").Rat;

my $im = Imlib2.new();
# load an image
my $loadedimage = $im.load_image("images/camelia-logo.jpg");
exit() unless $loadedimage;

# Sets the current image Imlib2 will be using with its function calls.
$loadedimage.context_set();

# Creates a new empty color modifier
my $color_modifier = $im.create_color_modifier();

# Sets the current color modifier used for rendering pixmaps or images
# to a drawable or images onto other images. Color modifiers are lookup
# tables that map the values in the red, green, blue and alpha channels
# to other values in the same channel when rendering, allowing for fades,
# color correction etc.
$color_modifier.context_set();

if $option == 1 {
	# Modifies the current color modifier by adjusting the brightness by the
	# value brightness_value. The color modifier is modified not set, so
	# calling this repeatedly has cumulative effects. brightness values of 0
	# do not affect anything. -1.0 will make things completely black and 1.0
	# will make things all white. Values in-between vary brightness linearly.
	$im.modify_color_modifier_brightness($value);
}

if $option == 2 {
	# Modifies the current color modifier by adjusting the contrast by the
	# value contrast_value. The color modifier is modified not set, so calling
	# this repeatedly has cumulative effects. Contrast of 1.0 does nothing.
	# 0.0 will merge to gray, 2.0 will double contrast etc.
	$im.modify_color_modifier_contrast($value);
}

if $option == 3 {
	# Modifies the current color modifier by adjusting the gamma by the value
	# specified gamma_value. The color modifier is modified not set, so calling
	# this repeatedly has cumulative effects. A gamma of 1.0 is normal linear,
	# 2.0 brightens and 0.5 darkens etc. Negative values are not allowed.
	$im.modify_color_modifier_gamma($value);
}

# Works the same way as apply_color_modifier() but only modifies a
# selected rectangle in the current image.
$im.apply_color_modifier_to_rectangle(
	x      => 20,
	y      => 20,
	width  => 200,
	height => 200
);

$im.free_color_modifier();

$im.image_set_format("png");
unlink("images/test_adjust.png") if "images/test_adjust.png".IO ~~ :e;
$im.save_image("images/test_adjust.png");

# Frees the image that is set as the current image in Imlib2's context. 
$im.free_image();

exit();
