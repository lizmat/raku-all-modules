use Imlib2;

my $im = Imlib2.new();

my $loadedimage = $im.load_image("images/camelia-logo.jpg");
exit() unless $loadedimage;
$loadedimage.context_set();

say "
Menu
-----------
1 - Flip
2 - Rotate
3 - Tile
4 - Blur
5 - Sharpen
0 - Exit
";

my $option = prompt("Please select a modification: ");

if $option == 1 {
	say "
Flip
--------------
1 - Horizontal
2 - Vertical
3 - Diagonal
0 - Exit
	";
	my $selected = prompt("Please select a mode: ");
	my $mode;
	given $option {
		when 1 { $mode = IMLIB_FLIP_HORIZONTAL; }
		when 2 { $mode = IMLIB_FLIP_VERTICAL; }
		when 3 { $mode = IMLIB_FLIP_DIAGONAL; }
		default { $im.free_image(); exit(); }
	}
	$im.image_flip($mode);
} elsif $option == 2 {
	say "
Rotate
----------------------
1 - Rotate 90 Degrees
2 - Rotate 180 Degrees
3 - Rotate 270 Degrees
0 - Exit
	";
	my $selected = prompt("Please select a mode: ");
	my $mode;
	given $option {
		when 1 { $mode = IMLIB_ROTATE_90_DEGREES; }
		when 2 { $mode = IMLIB_ROTATE_180_DEGREES; }
		when 3 { $mode = IMLIB_ROTATE_270_DEGREES; }
		default { say "Exit..."; $im.free_image(); exit(); }
	}
	$im.image_orientate($mode);
} elsif $option == 3 {
	say "
Tile
--------------
1 - Horizontal
2 - Vertical
3 - Both
0 - Exit
	";
	my $selected = prompt("Please select a mode: ");
	my $mode;
	given $option {
		when 1 { $mode = IMLIB_TILE_HORIZONTAL; }
		when 2 { $mode = IMLIB_TILE_VERTICAL; }
		when 3 { $mode = IMLIB_TILE_BOTH; }
		default { say "Exit..."; $im.free_image(); exit(); }
	}
	$im.image_tile($mode);
} elsif $option == 4 {
	say "
Blur
-------------
";
	my $value = prompt("Please select a value between 0 and 128: ").Int;
	unless 0 <= $value <= 180 { say "Exit: Wrong value..."; $im.free_image(); exit(); }
	$im.image_blur($value);
} elsif $option == 5 {
	say "
Sharpen
-------------
";
	my $value = prompt("Please select a value between 0 and 128: ").Int;
	unless 0 <= $value <= 180 { say "Exit: Wrong value..."; $im.free_image(); exit(); }
	$im.image_sharpen($value);
} else {
	say "Exit...";
	$im.free_image();
	exit();
}

say "Filename: " ~ $im.image_get_filename();
say "Format: " ~ $im.image_get_format();

my ($w, $h) = $im.image_get_size();
say "Width: $w";
say "Height: $h";

$im.image_set_format("png");

unlink("images/test_image_modification.png") if "images/test_image_modification.png".IO ~~ :e;

$im.save_image("images/test_image_modification.png");
$im.free_image();

exit();
