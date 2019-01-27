use v6;
use Test;

plan 19;

use Imlib2;

my $test_file = "t/test.png";
my $test_error_file = "t/test.jpg";

my $im = Imlib2.new();

my $rawimage = $im.create_image(100, 200);
$rawimage.context_set();
$im.image_set_format("png");
unlink($test_file) if $test_file.IO ~~ :e;
$im.save_image($test_file);
lives-ok { $im.free_image(); }, 'free_image';

my $loadedimage = $im.load_image($test_file);
isa-ok $loadedimage, Imlib2::Image;
ok $loadedimage, 'load_image';
$loadedimage.context_set();
$im.free_image();

my $image_if_ct = $im.load_image(filename => $test_file, immediately => False, cache => True);
isa-ok $image_if_ct, Imlib2::Image;
ok $image_if_ct, 'imlib_load_image with named arguments';
$image_if_ct.context_set();
$im.free_image();

my $image_it_ct = $im.load_image(filename => $test_file, immediately => True, cache => True);
isa-ok $image_it_ct, Imlib2::Image;
ok $image_it_ct, 'imlib_load_image_immediately';
$image_it_ct.context_set();
$im.free_image();

my $image_if_cf = $im.load_image(filename => $test_file, immediately => False, cache => False);
isa-ok $image_if_cf, Imlib2::Image;
ok $image_if_cf, 'imlib_load_image_without_cache';
$image_if_cf.context_set();
$im.free_image();

my $image_it_cf = $im.load_image(filename => $test_file, immediately => True, cache => False);
isa-ok $image_it_cf, Imlib2::Image;
ok $image_it_cf, 'imlib_load_image_immediately_without_cache';
$image_it_cf.context_set();
$im.free_image();

my LoadError $error;
my $error_image = $im.load_image($test_file, $error);
isa-ok $error_image, Imlib2::Image;
ok $error_image, 'imlib_load_image_with_error_return';
is $error, IMLIB_LOAD_ERROR_NONE, 'imlib_load_image_with_error_return IMLIB_LOAD_ERROR_NONE';
$error_image.context_set();

$im.save_image("notexist/$test_file", $error);
is $error, IMLIB_LOAD_ERROR_PATH_COMPONENT_NON_EXISTANT, 'imlib_save_image_with_error_return IMLIB_LOAD_ERROR_PATH_COMPONENT_NON_EXISTANT';
$im.save_image($test_file, $error);
is $error, IMLIB_LOAD_ERROR_NONE, 'imlib_save_image_with_error_return IMLIB_LOAD_ERROR_NONE';

lives-ok { $im.free_image(True); }, 'imlib_free_image_and_decache';

my $fail_image = $im.load_image($test_error_file, $error);
is $error, IMLIB_LOAD_ERROR_FILE_DOES_NOT_EXIST, 'imlib_load_image_with_error_return IMLIB_LOAD_ERROR_FILE_DOES_NOT_EXIST';
$im.free_image() if $im.context_get_image();

lives-ok { $im.flush_loaders(); }, 'flush_loaders';

unlink($test_file) if $test_file.IO ~~ :e;
