use Imlib2;

my $im = Imlib2.new();
my $newimage = $im.create_image(200, 200);
exit() unless $newimage;

# Sets the current image Imlib2 will be using with its function calls.
$newimage.context_set();

$im.image_set_has_alpha(True);

# Sets the color with which text, lines and rectangles are drawn when
# being rendered onto an image.
$im.context_set_color(
	red   => 10,
	green => 127,
	blue  => 200,
	alpha => 255
);

$im.context_get_color(
	red   => my $red = 0,
	green => my $green = 0,
	blue  => my $blue = 0,
	alpha => my $alpha = 0
);

my $hex = $im.get_hex_color_code($red, $green, $blue, $alpha);

say "RGBA Color Space:";
say "-----------------";
say "__Red: " ~ $red;
say "Green: " ~ $green;
say "_Blue: " ~ $blue;
say "Alpha: " ~ $alpha;
say "__Hex: " ~ $hex;
say "";

$im.context_get_color(
	hue        => my $hue = 0,
	saturation => my $saturation = 0,
	value      => my $value = 0,
	alpha      => $alpha = 0
);

say "HSVA Color Space:";
say "-----------------";
say "_______Hue: " ~ $hue;
say "Saturation: " ~ $saturation;
say "_____Value: " ~ $value;
say "_____Alpha: " ~ $alpha;

$im.image_draw_rectangle(
	location => (0, 0),
	size     => (200, 200),
	fill     => True);

# Another way to set a color (color, alpha).
# alpha is optional and the deafult value is 255.

$im.context_set_color(0xff0000ff);

$im.image_draw_rectangle(
	location => (0, 0),
	size     => (200 - 20 , 200 - 20));

$im.image_set_format("png");
unlink("images/test_imlib2.png") if "images/test_imlib2.png".IO ~~ :e;
$im.save_image("images/test_imlib2.png");

# Frees the image that is set as the current image in Imlib2's context.
$im.free_image();

exit();
