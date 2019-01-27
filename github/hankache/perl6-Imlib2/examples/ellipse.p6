use Imlib2;

my $im = Imlib2.new();
my $raw_image = $im.create_image(200, 200);
$raw_image.context_set();

$im.context_set_color("#ffffff");
$im.image_draw_rectangle(
	location => (0, 0),
	size     => (200, 200),
	fill     => True);

$im.context_set_color("#00ff00");
$im.image_draw_ellipse(
	center    => (50, 50),
	amplitude => (40, 40),
	fill      => True);

$im.context_set_color("#000000");
$im.image_draw_ellipse(
	center    => (50, 50),
	amplitude => (40, 40));

$im.context_set_color("#0000ff");
$im.image_draw_ellipse(
	center    => (140, 130),
	amplitude => (45, 35),
	fill      => True);

$im.context_set_color("#ff0000");
$im.image_draw_ellipse(
	center    => (140, 130),
	amplitude => (45, 35));

$im.image_set_format("png");
unlink("images/test_ellipse.png") if "images/test_ellipse.png".IO ~~ :e;
$im.save_image("images/test_ellipse.png");

$im.free_image();

exit();
