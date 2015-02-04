#!/usr/bin/env perl6
#
# Note: the perl6 implementation is very slow...
#

BEGIN { @*INC.push('../lib') };

use Imlib2;

say "Create transparent image function implementations:";
say "[1] - Perl6";
say "[2] - C";
say "[0] - Exit";
my $option = prompt("Select the implementation: ");

exit() unless $option == 1 | 2;

my $start_time = time;
my $new_alpha = 64;

my $im = Imlib2.new();
my $source_image = $im.load_image("images/camelia-logo.jpg");
exit() unless $source_image;
$source_image.context_set();

my $dest_image;
$dest_image = create_transparent_image($source_image, $new_alpha) if $option == 1;
$dest_image = $source_image.create_transparent_image($new_alpha) if $option == 2;

exit() unless $dest_image;
$dest_image.context_set();

$im.image_set_format("png");
unlink("images/test_transparent.png") if "images/test_transparent.png".IO ~~ :e;
$im.save_image("images/test_transparent.png");
$im.free_image();

$source_image.context_set();
$im.free_image();

my $exec_time = time - $start_time;
say "Total execution time: $exec_time";

exit();


sub create_transparent_image($source_image, $new_alpha) {
	$source_image.context_set();
	my $width = $im.image_get_width();
	my $height = $im.image_get_height();
	
	my $dest_image = $im.create_image($width, $height);
	exit() unless $dest_image;
	$dest_image.context_set();
	$im.image_clear();
	$im.image_set_has_alpha(True);
	
	my ($red, $green, $blue, $alpha) = (0, 0, 0, 0);
	loop (my $y = 0; $y < $height; $y++) {
		loop (my $x = 0; $x < $width; $x++)  {
			$source_image.context_set();
			$im.image_query_pixel(
				location => ($x, $y),
				red      => $red,
				green    => $green,
				blue     => $blue,
				alpha    => $alpha
			);
			$im.context_set_color(
				red   => $red,
				green => $green,
				blue  => $blue,
				alpha => $new_alpha
			);
			$dest_image.context_set();
			$im.image_draw_pixel($x, $y);
		}
	}
	return $dest_image;
}
