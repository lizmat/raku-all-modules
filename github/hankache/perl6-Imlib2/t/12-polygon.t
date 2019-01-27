use v6;
use Test;

plan 15;

use Imlib2;

my $im = Imlib2.new();
my $rawimage = $im.create_image(100, 100);
$rawimage.context_set();

my $polygon = $im.polygon_new();
isa-ok $polygon, Imlib2::Polygon;
ok $polygon, 'polygon_new';

lives-ok { $polygon.add_point(1, 1); }, 'polygon add_point';
$polygon.add_point(4, 1);
$polygon.add_point(4, 3);
$polygon.add_point(2, 4);

is $polygon.contains_point(2, 4), True, 'polygon contains_point returns True';
is $polygon.contains_point(5, 3), False, 'contains_point returns False';

my @bounds = $polygon.get_bounds();
ok @bounds, 'polygon get_bounds';
is @bounds.elems, 4, 'the array contains 4 elements.';
is @bounds[0], 1, 'x coordinate of the upper left corner';
is @bounds[1], 1, 'y coordinate of the upper left corner';
is @bounds[2], 4, 'x coordinate of the lower right corner';
is @bounds[3], 4, 'y coordinate of the lower right corner';

lives-ok {
	$im.image_draw_polygon($polygon, closed => True, fill => False);
}, 'image_draw_polygon - closed flag is set to True and fill to False';
lives-ok {
	$im.image_draw_polygon($polygon, closed => False, fill => False);
}, 'image_draw_polygon - closed flag is set to False and fill to False';
lives-ok {
	$im.image_draw_polygon($polygon, closed => True, fill => True);
}, 'image_draw_polygon - closed flag is set to True and fill to True';

lives-ok { $polygon.free(); }, 'polygon free';

$im.free_image();
