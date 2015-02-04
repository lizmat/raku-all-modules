use v6;
use Test;

plan 38;

use Imlib2;

my $test_file = "t/test.png";

my $im = Imlib2.new();

my $rawimage = $im.create_image(100, 200);
$rawimage.context_set();

lives_ok { $im.image_set_format("png"); }, 'image_set_format';
is $im.image_get_format(), "png", 'image_format returns PNG format';

unlink($test_file) if $test_file.IO ~~ :e;
$im.save_image($test_file);
$im.free_image();

my $loadedimage = $im.load_image($test_file);
$loadedimage.context_set();

is $im.image_get_width(), 100, 'image_get_width - the image width is 100 pixels';
is $im.image_get_height(), 200, 'image_get_height - the image height is 200 pixels';

my ($width, $height) = $im.image_get_size();
is $width, 100, 'image_get_size - the image width is 100 pixels';
is $height, 200, 'image_get_size - the image height is 200 pixels';

is $im.image_get_filename(), $test_file, 'image_get_filename';

lives_ok { $im.image_set_has_alpha(True); }, 'image_set_has_alpha - set has alpha to True';
is $im.image_has_alpha(), True, 'image_has_alpha returns True';
lives_ok { $im.image_set_has_alpha(False); }, 'image_set_has_alpha - set has alpha to False';
is $im.image_has_alpha(), False, 'image_has_alpha returns False';

lives_ok { $im.image_set_changes_on_disk(); }, 'image_set_changes_on_disk';

my $structure = Imlib2::Border.new();
isa_ok $structure, Imlib2::Border;
ok $structure, 'set a new border object structure';

is $structure.left, 0, 'left border stored value is 0';
is $structure.right, 0, 'right border stored value is 0';
is $structure.top, 0, 'top border stored value is 0';
is $structure.bottom, 0, 'bottom border stored value is 0';

lives_ok {
	$structure.left = 1;
	$structure.right = 2;
	$structure.top = 3;
	$structure.bottom = 4;
}, 'fills the border structure with the values of the border';

my $border = $structure.init();
ok $border, 'returns a pointer which contains the values ​​of the structure';

lives_ok { $im.image_set_border($border); }, 'image_set_border';
lives_ok { $im.image_get_border($border); }, 'image_get_border';

lives_ok { $structure.get($border); }, 'get the values of the border stored in structure';

is $structure.left, 1, 'left border stored value is 1';
is $structure.right, 2, 'right border stored value is 2';
is $structure.top, 3, 'top border stored value is 3';
is $structure.bottom, 4, 'bottom border stored value is 4';

lives_ok {
	$structure.left = 10;
	$structure.right = 20;
	$structure.top = 30;
	$structure.bottom = 40;
}, 'fills the border structure with new the values of the border';

$structure.put($border);
$structure.get($border);

is $structure.left, 10, 'left border stored value is 10';
is $structure.right, 20, 'right border stored value is 20';
is $structure.top, 30, 'top border stored value is 30';
is $structure.bottom, 40, 'bottom border stored value is 40';

lives_ok { $im.image_set_irrelevant(format => True); }, 'image_set_irrelevant_format is set to True';
lives_ok { $im.image_set_irrelevant(format => False); }, 'image_set_irrelevant_format is set to False';
lives_ok { $im.image_set_irrelevant(border => True); }, 'image_set_irrelevant_border is set to True';
lives_ok { $im.image_set_irrelevant(border => False); }, 'image_set_irrelevant_border is set to False';
lives_ok { $im.image_set_irrelevant(alpha => True); }, 'image_set_irrelevant_alpha is set to True';
lives_ok { $im.image_set_irrelevant(alpha => False); }, 'image_set_irrelevant_alpha is set to False';

$im.free_image();
unlink($test_file) if $test_file.IO ~~ :e;

done;
