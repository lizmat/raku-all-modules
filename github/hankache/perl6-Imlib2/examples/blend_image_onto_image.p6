#!/usr/bin/env perl6

use Imlib2;

say "Operations:
[1] - Copy
[2] - Add
[3] - Subtract
[4] - Reshade
[0] - Exit";
my $option = prompt("Please selecct an operation: ");

my $operation = 0;
given $option {
	when 1 { $operation = IMLIB_OP_COPY; }
	when 2 { $operation = IMLIB_OP_ADD; }
	when 3 { $operation = IMLIB_OP_SUBTRACT; }
	when 4 { $operation = IMLIB_OP_RESHADE; }
	default { exit(); }
}

say "wait a moment and check the result...";

my $im = Imlib2.new();

my $parrot_img = $im.load_image("images/parrot.png");
exit() unless $parrot_img;

my $camelia_img = $im.load_image("images/camelia-logo.jpg");
exit() unless $camelia_img;

$parrot_img.context_set();

$im.context_set_operation($operation);

$im.blend_image_onto_image(
	source       => (
		image    => $camelia_img,
		location => (0, 0),
		size     => (200, 200)
	),
	destination  => (
		location => (10, 10),
		size     => (261, 243)
	),
	merge_alpha  => True
);

$im.image_set_format("png");
unlink("images/test_blend.png") if "images/test_blend.png".IO ~~ :e;
$im.save_image("images/test_blend.png");
$im.free_image();

$camelia_img.context_set();
$im.free_image();

exit();
