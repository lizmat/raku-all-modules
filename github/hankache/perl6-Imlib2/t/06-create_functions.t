use v6;
use Test;

plan 16;

use Imlib2;

my $im = Imlib2.new();

my $rawimage = $im.create_image(200, 300);
isa-ok $rawimage, Imlib2::Image;
ok $rawimage, 'create_image';
$rawimage.context_set();

my $cloned_image = $im.clone_image();
isa-ok $cloned_image, Imlib2::Image;
ok $cloned_image, 'clone_image';
$cloned_image.context_set();
$im.free_image();
$rawimage.context_set();

my $cropped_image = $im.create_resized_image(
	crop     => (150, 100));
isa-ok $cropped_image, Imlib2::Image;
ok $cropped_image, 'create_resized_image - cropped image without location';
$cropped_image.context_set();
$im.free_image();
$rawimage.context_set();

my $cropped_image_location = $im.create_resized_image(
	location => (20, 10),
	crop     => (150, 100));
isa-ok $cropped_image_location, Imlib2::Image;
ok $cropped_image_location, 'create_resized_image - cropped image with location';
$cropped_image_location.context_set();
$im.free_image();
$rawimage.context_set();

my $scaled_image = $im.create_resized_image(
	scale    => (150, 100));
isa-ok $scaled_image, Imlib2::Image;
ok $scaled_image, 'create_resized_image - scaled image without location';
$scaled_image.context_set();
$im.free_image();
$rawimage.context_set();

my $scaled_image_location = $im.create_resized_image(
	location => (50, 60),
	scale    => (150, 100));
isa-ok $scaled_image_location, Imlib2::Image;
ok $scaled_image_location, 'create_resized_image - scaled image with location';
$scaled_image_location.context_set();
$im.free_image();
$rawimage.context_set();

my $cropped_scaled_image = $im.create_resized_image(
	crop     => (150, 100),
	scale    => (300, 300));
isa-ok $cropped_scaled_image, Imlib2::Image;
ok $cropped_scaled_image, 'create_resized_image - cropped and scaled image without location';
$cropped_scaled_image.context_set();
$im.free_image();
$rawimage.context_set();

my $cropped_scaled_image_location = $im.create_resized_image(
	location => (50, 60),
	crop     => (150, 100),
	scale    => (300, 300));
isa-ok $cropped_scaled_image_location, Imlib2::Image;
ok $cropped_scaled_image_location, 'create_resized_image - cropped and scaled image with location';
$cropped_scaled_image_location.context_set();
$im.free_image();
$rawimage.context_set();

$im.free_image();
