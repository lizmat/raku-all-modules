use v6;
use Test;

plan 73;

use Imlib2;

my $im = Imlib2.new();

lives-ok { $im.context_set_dither_mask(True); }, 'context_set_dither_mask is set to True';
is $im.context_get_dither_mask(), True, 'context_get_dither_mask returns True';
lives-ok { $im.context_set_dither_mask(False); }, 'context_set_dither_mask is set to False';
is $im.context_get_dither_mask(), False, 'context_get_dither_mask returns False';

lives-ok { $im.context_set_anti_alias(True); }, 'context_set_anti_alias is set to True';
is $im.context_get_anti_alias(), True, 'context_get_anti_alias returns True';
lives-ok { $im.context_set_anti_alias(False); }, 'context_set_anti_alias is set to False';
is $im.context_get_anti_alias(), False, 'context_get_anti_alias returns False';

lives-ok { $im.context_set_mask_alpha_threshold(150); }, 'context_set_mask_alpha_threshold is set to 150';
is $im.context_get_mask_alpha_threshold(), 150, 'context_get_mask_alpha_threshold returns 150';

lives-ok { $im.context_set_dither(True); }, 'context_set_dither is set to True';
is $im.context_get_dither(), True, 'context_get_dither returns True';
lives-ok { $im.context_set_dither(False); }, 'context_set_dither is set to False';
is $im.context_get_dither(), False, 'context_get_dither returns False';

lives-ok { $im.context_set_blend(True); }, 'context_set_blend is set to True';
is $im.context_get_blend(), True, 'context_get_blend returns True';
lives-ok { $im.context_set_blend(False); }, 'context_set_blend is set to False';
is $im.context_get_blend(), False, 'context_get_blend returns False';

# imlib_context_set_color_modifier -> xx-color_modifiers.t
# imlib_context_get_color_modifier -> xx-color_modifiers.t

lives-ok { $im.context_set_operation(IMLIB_OP_COPY); }, 'context_set_operation is set to IMLIB_OP_COPY mode';
is $im.context_get_operation(), IMLIB_OP_COPY, 'context_get_operation returns IMLIB_OP_COPY mode';
lives-ok { $im.context_set_operation(IMLIB_OP_ADD); }, 'context_set_operation is set to IMLIB_OP_ADD mode';
is $im.context_get_operation(), IMLIB_OP_ADD, 'context_get_operation returns IMLIB_OP_ADD mode';
lives-ok { $im.context_set_operation(IMLIB_OP_SUBTRACT); }, 'context_set_operation is set to IMLIB_OP_SUBTRACT mode';
is $im.context_get_operation(), IMLIB_OP_SUBTRACT, 'context_get_operation returns IMLIB_OP_SUBTRACT mode';
lives-ok { $im.context_set_operation(IMLIB_OP_RESHADE); }, 'context_set_operation is set to IMLIB_OP_RESHADE mode';
is $im.context_get_operation(), IMLIB_OP_RESHADE, 'context_get_operation returns IMLIB_OP_RESHADE mode';

# context_set_font -> xx-fonts_and_text.t
# context_get_font -> xx-fonts_and_text.t

lives-ok { $im.context_set_direction(IMLIB_TEXT_TO_RIGHT); }, 'context_set_direction is set to IMLIB_TEXT_TO_RIGHT';
is $im.context_get_direction(), IMLIB_TEXT_TO_RIGHT, 'context_get_direction returns IMLIB_TEXT_TO_RIGHT';
lives-ok { $im.context_set_direction(IMLIB_TEXT_TO_LEFT); }, 'context_set_direction is set to IMLIB_TEXT_TO_LEFT';
is $im.context_get_direction(), IMLIB_TEXT_TO_LEFT, 'context_get_direction returns IMLIB_TEXT_TO_LEFT';
lives-ok { $im.context_set_direction(IMLIB_TEXT_TO_DOWN); }, 'context_set_direction is set to IMLIB_TEXT_TO_DOWN';
is $im.context_get_direction(), IMLIB_TEXT_TO_DOWN, 'context_get_direction returns IMLIB_TEXT_TO_DOWN';
lives-ok { $im.context_set_direction(IMLIB_TEXT_TO_UP); }, 'context_set_direction is set to IMLIB_TEXT_TO_UP';
is $im.context_get_direction(), IMLIB_TEXT_TO_UP, 'context_get_direction returns IMLIB_TEXT_TO_UP';
lives-ok { $im.context_set_direction(IMLIB_TEXT_TO_ANGLE); }, 'context_set_direction is set to IMLIB_TEXT_TO_ANGLE';
is $im.context_get_direction(), IMLIB_TEXT_TO_ANGLE, 'context_get_direction returns IMLIB_TEXT_TO_ANGLE';

lives-ok { $im.context_set_angle(-45.0); }, 'context_set_angle is set to -45.0';
is $im.context_get_angle(), -45.0, 'context_get_angle returns -45.0';

lives-ok {
	$im.context_set_color("#ff0000");
}, 'context_set_color with hexadecimal color string rgb';
lives-ok {
	$im.context_set_color("#ff00ffff");
}, 'context_set_color with hexadecimal color string rgba';
lives-ok {
	$im.context_set_color(0xffffffff);
}, 'context_set_color with hexadecimal color number';

# Color in RGBA space

lives-ok {
	$im.context_set_color(
		red   => 50,
		green => 100,
		blue  => 150,
		alpha => 200);
}, 'imlib_context_set_color - sets the color channel in RGBA color space';

my ($red, $green, $blue, $alpha);
lives-ok {
	$im.context_get_color(
		red   => $red = 0,
		green => $green = 0,
		blue  => $blue = 0,
		alpha => $alpha = 0);
}, 'imlib_context_get_color - gets the colors channel in RGBA color space';

is $red, 50, 'returns the value 50 for red color channel';
is $green, 100, 'returns the value 100 for green color channel';
is $blue, 150, 'returns the value 150 for blue color channel';
is $alpha, 200, 'returns the value 200 for alpha color channel';

my $hex = $im.get_hex_color_code($red, $green, $blue, $alpha);
is $hex, "#326496c8", 'get_hex_color_code returns the code #326496c8';

# Color in HSVA space

lives-ok {
	$im.context_set_color(
		hue        => 55,
		saturation => 15,
		value      => 95,
		alpha      => 205);
}, 'imlib_context_set_color_hsva - sets the color channel in HSVA color space';

my ($hue, $saturation, $value);
lives-ok {
	$im.context_get_color(
		hue        => $hue = 0,
		saturation => $saturation = 0,
		value      => $value = 0,
		alpha      => $alpha = 0);
}, 'imlib_context_get_color_hsva - gets the colors channel in HSVA color space';

#is $hue, 55, 'returns the value 55 for hue color channel';
#is $saturation, 15, 'returns the value 15 for saturation color channel';
#is $value, 95, 'returns the value 95 for value color channel';
is $alpha, 205, 'returns the value 205 for alpha color channel';

# Color in HLSA space

lives-ok {
	$im.context_set_color(
		hue        => 60,
		lightness  => 25,
		saturation => 85,
		alpha      => 210);
}, 'imlib_context_set_color_hlsa - sets the color channel in HLSA color space';

my $lightness;
lives-ok {
	$im.context_get_color(
		hue        => $hue = 0,
		lightness  => $lightness = 0,
		saturation => $saturation = 0,
		alpha      => $alpha = 0);
}, 'imlib_context_get_color_hlsa - gets the colors channel in HLSA color space';

#is $hue, 60, 'returns the value 60 for hue color channel';
#is $lightness, 25, 'returns the value 25 for lightness color channel';
#is $saturation, 85, 'returns the value 85 for saturation color channel';
is $alpha, 210, 'returns the value 210 for alpha color channel';

# Color in CMYA space

lives-ok {
	$im.context_set_color(
		cyan    => 65,
		magenta => 115,
		yellow  => 165,
		alpha   => 215);
}, 'imlib_context_set_color_cmya - sets the color channel in CMYA color space';

my ($cyan, $magenta, $yellow);
lives-ok {
	$im.context_get_color(
		cyan    => $cyan = 0,
		magenta => $magenta = 0,
		yellow  => $yellow = 0,
		alpha   => $alpha = 0);
}, 'imlib_context_get_color_cmya - gets the colors channel in CMYA color space';

is $cyan, 65, 'returns the value 65 for cyan color channel';
is $magenta, 115, 'returns the value 115 for magenta color channel';
is $yellow, 165, 'returns the value 165 for yellow color channel';
is $alpha, 215, 'returns the value 215 for alpha color channel';

# context_set_color_range -> xx-color_range.t
# context_get_color_range -> xx-color_range.t

my $rawimage = $im.create_image(100, 200);
lives-ok { $rawimage.context_set(); }, 'context_set image';
my $get_rawimage = $im.context_get_image();
isa-ok $get_rawimage, Imlib2::Image;
ok $get_rawimage, 'context_get_image';

lives-ok {
	$im.context_set_cliprect(x => 10, y => 25, width => 100, height => 125);
}, 'context_set_cliprect';

my ($x, $y, $width, $height);
lives-ok {
	$im.context_get_cliprect(
		x      => $x = 0,
		y      => $y = 0,
		width  => $width = 0,
		height => $height = 0);
}, 'imlib_context_get_cliprect - gets the rectangle of the current context';

is $x, 10, 'the top left x coordinate of the rectangle is 10';
is $y, 25, 'the top left y coordinate of the rectangle is 25';
is $width, 100, 'the width of the rectangle is 100';
is $height, 125, 'the height of the rectangle is 125';

lives-ok { $im.set_cache_size(2048 * 1024); }, 'set_cache_size';
is $im.get_cache_size(), 2048 * 1024, 'the cache size is set to 2048 * 1024 bytes';

lives-ok { $im.set_color_usage(256); }, 'set_color_usage';
is $im.get_color_usage(), 256, 'the current number of colors is 256';

$im.free_image();
