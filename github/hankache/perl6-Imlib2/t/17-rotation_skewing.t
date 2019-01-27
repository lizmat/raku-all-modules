use v6;
use Test;

plan 2;

use Imlib2;

my $im = Imlib2.new();
my $raw_image = $im.create_image(100, 200);
$raw_image.context_set();

my $rotated_image = $im.create_rotated_image(45.0);
isa-ok $rotated_image, Imlib2::Image;
ok $rotated_image, 'create_rotated_image';

$rotated_image.context_set();
$im.free_image();

$raw_image.context_set();
$im.free_image();
