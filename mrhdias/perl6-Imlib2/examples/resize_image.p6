#!/usr/bin/env perl6

BEGIN { @*INC.push('../lib') };

use Imlib2;

my $im = Imlib2.new();

my $loadedimage = $im.load_image("images/camelia-logo.jpg");
exit() unless $loadedimage;

$loadedimage.context_set();

my $cropped = $im.create_resized_image(
	crop     => (150, 100));
$cropped.context_set();
save_image($im, "test_cropped.png");
$loadedimage.context_set();

my $cropped_loc = $im.create_resized_image(
	location => (20, 10),
	crop     => (150, 100));
$cropped_loc.context_set();
save_image($im, "test_cropped_loc.png");
$loadedimage.context_set();

my $scaled = $im.create_resized_image(
	scale    => (150, 100));
$scaled.context_set();
save_image($im, "test_scaled.png");
$loadedimage.context_set();

my $scaled_loc = $im.create_resized_image(
	location => (50, 60),
	scale    => (150, 100));
$scaled_loc.context_set();
save_image($im, "test_scaled_loc.png");
$loadedimage.context_set();

my $cropped_scaled = $im.create_resized_image(
	crop     => (150, 100),
	scale    => (300, 300));
$cropped_scaled.context_set();
save_image($im, "test_cropped_scaled.png");
$loadedimage.context_set();

my $cropped_scaled_loc = $im.create_resized_image(
	location => (50, 60),
	crop     => (150, 100),
	scale    => (300, 300));
$cropped_scaled_loc.context_set();
save_image($im, "test_cropped_scaled_loc.png");
$loadedimage.context_set();

$im.free_image();

exit();

sub save_image($im, $filename) {
	$im.image_set_format("png");
	unlink("images/$filename") if "images/$filename".IO ~~ :e;
	$im.save_image("images/$filename");
	$im.free_image();
}
