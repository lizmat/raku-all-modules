use v6;
use Test;

plan 18;

use Imlib2;

my $im = Imlib2.new();

my $raw_image = $im.create_image(200, 200);
$raw_image.context_set();

my $color_modifier = $im.create_color_modifier();
isa_ok $color_modifier, Imlib2::ColorModifier;
ok $color_modifier, 'imlib_create_color_modifier';

lives_ok { $color_modifier.context_set(); }, 'imlib_context_set_color_modifier';

my $get_color_modifier = $im.context_get_color_modifier();
isa_ok $get_color_modifier, Imlib2::ColorModifier;
ok $get_color_modifier, 'imlib_context_get_color_modifier';

my @red_table = ();
@red_table[$_] = 0 for 0..255;
my @alpha_table = my @blue_table = my @green_table = @red_table;

@red_table[127] = 8;
@green_table[127] = 16;
@blue_table[127] = 32;
@alpha_table[127] = 64;

lives_ok {
	$im.set_color_modifier_tables(
		@red_table,
		@green_table,
		@blue_table,
		@alpha_table);
 }, 'imlib_set_color_modifier_tables';

lives_ok {
	$im.get_color_modifier_tables(
		@red_table,
		@green_table,
		@blue_table,
		@alpha_table);
}, 'imlib_get_color_modifier_tables';

is @red_table[127], 8, 'The value of position 127 of the red table is 8.';
is @green_table[127], 16, 'The value of position 127 of the green table is 16.';
is @blue_table[127], 32, 'The value of position 127 of the blue table is 32.';
is @alpha_table[127], 64, 'The value of position 127 of the alpha table is 64.';
 
lives_ok { $im.reset_color_modifier(); }, 'imlib_reset_color_modifier';

lives_ok { $im.modify_color_modifier(gamma => 10); }, 'imlib_modify_color_modifier_gamma';
lives_ok { $im.modify_color_modifier(brightness => 20); }, 'imlib_modify_color_modifier_brightness';
lives_ok { $im.modify_color_modifier(contrast   => 30); }, 'imlib_modify_color_modifier_contrast';

lives_ok { $im.apply_color_modifier(); }, 'imlib_apply_color_modifier';

lives_ok { $im.apply_color_modifier(
	location => (20, 20),
	size     => (180, 180)
); }, 'imlib_apply_color_modifier_to_rectangle';

lives_ok { $im.free_color_modifier(); }, 'imlib_free_color_modifier';

$im.free_image();

done;
