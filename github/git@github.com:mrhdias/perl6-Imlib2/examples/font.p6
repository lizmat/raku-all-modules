#!/usr/bin/env perl6

BEGIN { @*INC.push('../lib') };

use Imlib2;

my $im = Imlib2.new();
# load an image
my $loadedimage = $im.load_image("images/camelia-logo.jpg");
exit() unless $loadedimage;

# Sets the current image Imlib2 will be using with its function calls.
$loadedimage.context_set();

$im.add_path_to_font_path("/usr/share/fonts/corefonts");
$im.set_font_cache_size(512 * 1024);
my $bytes = $im.get_font_cache_size();
say "Font cache size: $bytes";

$im.context_set_color(
	red   => 255,
	green => 0,
	blue  => 0,
	alpha => 255
);

# load another font: /usr/share/fonts/corefonts/comic.ttf
my $corefont = $im.load_font("comic", 36);

# Sets the current font to use when rendering text
$corefont.context_set();

# Sets the direction in which to draw text in terms of simple 90 degree
# orientations or an arbitrary angle. The direction can be one of:
# IMLIB_TEXT_TO_RIGHT, IMLIB_TEXT_TO_LEFT, IMLIB_TEXT_TO_DOWN,
# IMLIB_TEXT_TO_UP or IMLIB_TEXT_TO_ANGLE. The default is
# IMLIB_TEXT_TO_RIGHT. If you use IMLIB_TEXT_TO_ANGLE, you will also
# have to set the angle with context_set_angle().
$im.context_set_direction(IMLIB_TEXT_TO_ANGLE);

say "Text to Angle..." if $im.context_get_direction() == IMLIB_TEXT_TO_ANGLE;

$im.context_set_angle(-45.0);

say "Text Direction Angle: " ~ $im.context_get_angle();

# Draws the null-byte terminated string text using the current font on
# the current image at the (x, y) location (x, y denoting the top left
# corner of the font string).
$im.text_draw(10, 10, "Imlib2");

# load another font: /usr/share/fonts/corefonts/verdana.ttf
my $verdanafont = $im.load_font("verdana", 24);

# Sets the current font to verdana
$verdanafont.context_set();

$im.context_set_color(
	red   => 0,
	green => 255,
	blue  => 0,
	alpha => 255
);

# Gets the width and height in pixels the text string would use up if
# drawn with the current font
my $text = "Perl 6";
my ($tw, $th) = $im.get_text_size($text);

$im.text_draw(($tw/2).Int, ($th/2).Int, $text);

# Frees the font list
$im.free_font();

$im.image_set_format("png");
unlink("images/test_font.png") if "images/test_font.png".IO ~~ :e;
$im.save_image("images/test_font.png");

# Frees the image that is set as the current image in Imlib2's context. 
$im.free_image();

exit();
