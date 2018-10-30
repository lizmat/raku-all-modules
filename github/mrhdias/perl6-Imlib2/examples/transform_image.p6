#!/usr/bin/env perl6

BEGIN { @*INC.push('../lib') };

use Imlib2;

my $im = Imlib2.new();
my $loaded_image = $im.load_image("images/camelia-logo.jpg");
exit() unless $loaded_image;
$loaded_image.context_set();

$im.image_set_format("png");

$im.image_flip(IMLIB_FLIP_HORIZONTAL);

$im.image_orientate(IMLIB_ROTATE_90_DEGREES);

unlink("images/test_transform.png") if "images/test_transform.png".IO ~~ :e;
$im.save_image("images/test_transform.png");

my $rotated_image = $im.create_rotated_image(-45.0);
$rotated_image.context_set();

unlink("images/test_rotated.png") if "images/test_rotated.png".IO ~~ :e;
$im.save_image("images/test_rotated.png");

$im.free_image();

$loaded_image.context_set();
$im.free_image();

exit();
