use Imlib2;

my $im = Imlib2.new();
my $loadedimage = $im.load_image("images/camelia-logo.jpg");
exit() unless $loadedimage;

$loadedimage.context_set();

my $polygon = $im.polygon_new();
exit() unless $polygon;

my @points = (
	 30,  30, # upper left corner
	180,  10, # upper right corner
	180, 180, # lower right corner
	 60, 190  # lower left corner
);
for @points -> Int $x, Int $y {
	$polygon.add_point($x, $y);
}

if $polygon.contains_point(50, 100) {
	say "YES contain the point....";
}

my @bounds = $polygon.get_bounds();
say "X coordinate of the upper left corner: " ~ @bounds[0];
say "Y coordinate of the upper left corner: " ~ @bounds[1];
say "X coordinate of the lower right corner: " ~ @bounds[2];
say "Y coordinate of the lower right corner: " ~ @bounds[3];

$im.context_set_color(
	red   => 255,
	green => 0,
	blue  => 0,
	alpha => 255
);

$im.image_draw_polygon($polygon);

$im.context_set_color(
	red   => 255,
	green => 0,
	blue  => 255,
	alpha => 127
);

$im.image_draw_polygon($polygon, fill => True);

$polygon.free();

$im.image_set_format("png");
unlink("images/test_polygon.png") if "images/test_polygon.png".IO ~~ :e;
$im.save_image("images/test_polygon.png");
$im.free_image();

exit();
