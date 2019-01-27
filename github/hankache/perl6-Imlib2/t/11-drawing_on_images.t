use v6;
use Test;

plan 9;

use Imlib2;

my $im = Imlib2.new();
my $raw_image = $im.create_image(200, 200);
$raw_image.context_set();

$im.context_set_color(0xffffffff);

lives-ok {
	$im.image_draw_pixel(10, 10, False);
}, 'image_draw_pixel with update option set to False';

my $updates_draw_pixel = $im.image_draw_pixel(10, 10, True);
isa-ok $updates_draw_pixel, Imlib2::Updates;
ok $updates_draw_pixel, 'image_draw_pixel with update option set to True';

lives-ok {
	$im.image_draw_line(
		start => (10, 10),
		end   => (190, 190),
		update => False);
}, 'image_draw_line with update option set to False';

my $updates_draw_line = $im.image_draw_line(
	start => (10, 10),
	end   => (190, 190),
	update => True);
isa-ok $updates_draw_line, Imlib2::Updates;
ok $updates_draw_line, 'image_draw_line with update option set to True';

lives-ok {
	$im.image_draw_rectangle(
		location => (0, 0),
		size     => (200, 200),
		fill     => True);
}, 'image_draw_rectangle - fill is set to True';

$im.context_set_color(0x000000ff);
lives-ok {
	$im.image_draw_rectangle(
		location => (0, 0),
		size     => (200, 200));
}, 'image_draw_rectangle - fill is set to False';

lives-ok {
	$im.image_draw_rectangle(
		size     => (200, 200));
}, 'image_draw_rectangle - without location';

$im.free_image();
