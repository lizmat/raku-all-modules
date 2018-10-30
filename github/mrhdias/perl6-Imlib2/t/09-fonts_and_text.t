use v6;
use Test;

plan 33;

use Imlib2;

my $im = Imlib2.new();

my $rawimage = $im.create_image(200, 200);
$rawimage.context_set();

lives_ok {
	$im.add_path_to_font_path("t/fonts");
}, 'add_path_to_font_path - add "t/fonts" path';

my @list_font_path = $im.list_font_path();
is @list_font_path.elems, 1, 'list_font_path - the list has one element';
is @list_font_path[0], "t/fonts", 'list_font_path - the only value is the path t/fonts';

my @list_font = $im.list_fonts();
is @list_font.elems, 1, 'list_font - the list has one element';
is @list_font[0], "comic", 'list_font - the only value is the comic font';

lives_ok {
	$im.flush_font_cache();
}, 'flush_font_cache';

lives_ok {
	$im.set_font_cache_size(512 * 1024);
}, 'font_cache_size - the cache size is set to 512 * 1024 bytes';

is $im.get_font_cache_size(), 512 * 1024, 'font_cache_size returns 512 * 1024 bytes';

my $corefont = $im.load_font("comic", 36);
isa_ok $corefont, Imlib2::Font;
ok $corefont, 'load_font';
lives_ok { $corefont.context_set(); }, 'context_set font';

my $get_font = $im.context_get_font();
isa_ok $get_font, Imlib2::Font;
ok $get_font, 'context_get_font';

lives_ok { $im.text_draw(10, 10, "abc"); }, 'text_draw';

my %returned_metrics;
lives_ok {
	$im.text_draw(10, 10, "abc", %returned_metrics);
}, 'text_draw with return metrics';

is %returned_metrics{'width'}, 78, 'the width of the string is 78 pixels';
is %returned_metrics{'height'}, 66, 'the height of the string is 66 pixels';
is %returned_metrics{'horizontal_advance'}, 78, 'the horizontal offset is 78 pixels';
is %returned_metrics{'vertical_advance'}, 66, 'the vertical offset is 66 pixels';

my $width = 0;
my $height = 0;
lives_ok {
	($width, $height) = $im.get_text_size("test");
}, 'imlib_get_text_size';
is $width, 94, 'the width of the string is 94 pixels';
is $height, 66, 'the height of the string is 66 pixels';

my $horizontal_advance = 0;
my $vertical_advance = 0;
lives_ok {
	($horizontal_advance, $vertical_advance) = $im.get_text_advance("test");
}, 'imlib_get_text_advance';
is $horizontal_advance, 95, 'the horizontal offset is 78 pixels';
is $vertical_advance, 66, 'the vertical offset is 66 pixels';

is $im.get_text_inset("ABCDEF"), -3, 'get_text_inset returns -3 pixels';

#my %character;
#my $char_number = $im.text_get_index_and_location("perl6", 5, 5, %character);
#is $char_number, -1, 'text_get_index_and_location returns -1';

#my %geometry;
#lives_ok { $im.text_get_location_at_index("perl6", 5, 5, %geometry); }, 'text_get_location_at_index';

is $im.get_font_ascent(), 52, 'get_font_ascent returns 52 pixels';
is $im.get_font_descent(), 13, 'get_font_descent returns 13 pixels';

is $im.get_maximum_font_ascent(), 52, 'get_maximum_font_ascent returns 52 pixels';
is $im.get_maximum_font_descent(), -14, 'get_maximum_font_descent returns -14 pixels';

lives_ok { $im.free_font(); }, 'free_font';

lives_ok {
	$im.remove_path_from_font_path("t/fonts");
}, 'remove_path_from_font_path - remove "t/fonts" path';

$corefont = $im.load_font("comic", 36);
is $corefont.Bool, False, 'load_font - no font found';

$im.free_image();

done;
