use v6;
use Test;

plan 4;

use Imlib2;

my $im = Imlib2.new();
my $raw_image = $im.create_image(200, 200);
$raw_image.context_set();

lives_ok {
	$im.image_draw_ellipse(
		center    => (100, 200),
		amplitude => (40, 50));
}, 'image_draw_ellipse - fill is set to False';

lives_ok {
	$im.image_draw_ellipse(
		center    => (100, 200),
		amplitude => (40, 50),
		fill      => True);
}, 'image_draw_ellipse - fill is set to True';

lives_ok {
	$im.image_draw_circumference(
		center => (100, 100),
		radius => 40);
}, 'image_draw_circumference - fill is set to False';

lives_ok {
	$im.image_draw_circumference(
		center => (100, 100),
		radius => 40,
		fill   => True);
}, 'image_draw_circumference - fill is set to True';

$im.free_image();

done;
