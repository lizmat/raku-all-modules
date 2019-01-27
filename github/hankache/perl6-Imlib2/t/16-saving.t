use v6;
use Test;

plan 3;

use Imlib2;

my $im = Imlib2.new();

my $test_file = "t/test.png";

my $rawimage = $im.create_image(100, 200);
$rawimage.context_set();

$im.image_set_format("png");

unlink($test_file) if $test_file.IO ~~ :e;
lives-ok { $im.save_image($test_file); }, 'save_image';

unlink($test_file) if $test_file.IO ~~ :e;

my LoadError $error;
$im.save_image("notexist/$test_file", $error);
is $error, IMLIB_LOAD_ERROR_PATH_COMPONENT_NON_EXISTANT, 'imlib_save_image_with_error_return IMLIB_LOAD_ERROR_PATH_COMPONENT_NON_EXISTANT';
$im.save_image($test_file, $error);
is $error, IMLIB_LOAD_ERROR_NONE, 'imlib_save_image_with_error_return IMLIB_LOAD_ERROR_NONE';

$im.free_image();

unlink($test_file) if $test_file.IO ~~ :e;
