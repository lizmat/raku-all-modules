use v6;
use Test;

plan 1;

use Imlib2;

my $im = Imlib2.new();

my $source_file = $im.create_image(100, 100);
my $dest_file = $im.create_image(200, 200);

$dest_file.context_set();

lives-ok { 
	$im.blend_image_onto_image(
		source       => (
			image    => $source_file,
			location => (0, 0),
			size     => (100, 100)
		),
		destination  => (
			location => (10, 10),
			size     => (50, 50)
		),
		merge_alpha  => True);
}, 'blend_image_onto_image';

$im.free_image();
$source_file.context_set();
$im.free_image();
