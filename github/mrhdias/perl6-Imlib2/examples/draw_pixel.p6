#!/usr/bin/env perl6

BEGIN { @*INC.push('../lib') };

use Imlib2;

my $im = Imlib2.new();
my $new_image = $im.create_image(200, 200);
exit() unless $new_image;

my @colors = ("#ff0000", "#00ff00", "#0000ff", "#ffff00", "#ff00ff");

$new_image.context_set();

$im.context_set_color("#000000");
$im.image_draw_rectangle(
	location => (0, 0),
	size     => (200, 200),
	fill     => True);

# Ok, let's make noise.
for 1..200 {
	my $x = (0 .. 200).pick;
	my $y = (0 .. 200).pick;
	$im.context_set_color(@colors.pick);
	$im.image_draw_pixel($x, $y, False); # False is optional
}

$im.image_set_format("png");
unlink("images/test_draw_pixel.png") if "images/test_draw_pixel.png".IO ~~ :e;
$im.save_image("images/test_draw_pixel.png");

$im.free_image();
