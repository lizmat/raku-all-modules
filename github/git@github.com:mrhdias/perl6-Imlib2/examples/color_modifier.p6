#!/usr/bin/env perl6

BEGIN { @*INC.push('../lib') };

use Imlib2;

my $im = Imlib2.new();

# load an image
my $loadedimage = $im.load_image("images/camelia-logo.jpg");
exit() unless $loadedimage;

# Sets the current image Imlib2 will be using with its function calls.
$loadedimage.context_set();

$im.context_set_blend(True);

$im.image_set_has_alpha(False);

my $color_modifier = $im.create_color_modifier();

$color_modifier.context_set();

$im.image_set_has_alpha(True);

# Initialize the array tables
my @red_table = ();
@red_table[$_] = 0 for 0..255;

my @alpha_table = my @blue_table = my @green_table = @red_table;

$im.reset_color_modifier();

$im.get_color_modifier_tables(
	@red_table,
	@green_table,
	@blue_table,
	@alpha_table);

for 0..255 {
	say "[" ~ join("] [", @red_table[$_], @green_table[$_], @blue_table[$_], @alpha_table[$_]) ~ "]";
}

# reverse
loop (my $i = 0; $i <= 255; $i++) {
	@red_table[255-$i] = $i;
	@green_table[255-$i] = $i;
	@blue_table[255-$i] = $i;
	@alpha_table[$i] = 127;
}

$im.set_color_modifier_tables(
	@red_table,
	@green_table,
	@blue_table,
	@alpha_table);

$im.modify_color_modifier(
	contrast   => 0,
	brightness => 0,
	gamma      => 127
);

$im.apply_color_modifier(
	location => (20, 20),
	size     => (200, 200)
);

$im.free_color_modifier();

$im.image_set_format("png");
unlink("images/test_color_modifier.png") if "images/test_color_modifier.png".IO ~~ :e;
$im.save_image("images/test_color_modifier.png");
$im.free_image();

exit();
