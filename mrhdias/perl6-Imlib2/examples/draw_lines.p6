#!/usr/bin/env perl6

BEGIN { @*INC.push('../lib') };

use Imlib2;

my $im = Imlib2.new();
my $new_image = $im.create_image(200, 200);
exit() unless $new_image;

$new_image.context_set();

$im.context_set_color("#ffffff");
$im.image_draw_rectangle(
	location => (0, 0),
	size     => (200, 200),
	fill     => True);

$im.context_set_color("#000000");
$im.image_draw_line(
	start => (10, 10),
	end   => (190, 190),
	update => False);

$im.context_set_color("#ff0000");
$im.image_draw_line(
	start => (190, 10),
	end   => (10, 190),
	update => False);

$im.image_set_format("png");
unlink("images/test_draw_lines.png") if "images/test_draw_lines.png".IO ~~ :e;
$im.save_image("images/test_draw_lines.png");

$im.free_image();
