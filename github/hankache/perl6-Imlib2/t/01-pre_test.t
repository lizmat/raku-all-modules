use v6;
use Test;

plan 10;

use Imlib2;

my $test_file = "t/test.png";

my $im = Imlib2.new();

my $color_modifier = $im.create_color_modifier();
isa-ok $color_modifier, Imlib2::ColorModifier;
ok $color_modifier, 'create_color_modifier';
lives-ok { $color_modifier.context_set(); }, 'context_set color_modifier';
lives-ok { $im.free_color_modifier(); }, 'free_color_modifier';

my $rawimage = $im.create_image(100, 200);
isa-ok $rawimage, Imlib2::Image;
ok $rawimage, 'create_image';
lives-ok { $rawimage.context_set(); }, 'context_set image';
lives-ok { $im.image_set_format("png"); }, 'image_set_format';

unlink($test_file) if $test_file.IO ~~ :e;
lives-ok { $im.save_image($test_file); }, 'save_image';
lives-ok { $im.free_image(); }, 'free_image';
unlink($test_file) if $test_file.IO ~~ :e;

