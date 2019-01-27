use Imlib2;

my $im = Imlib2.new();
my $loadedimage = $im.load_image("images/camelia-logo.jpg");
exit() unless $loadedimage;

$loadedimage.context_set();

my $structure = Imlib2::Border.new(
	left   => 10,
	right  => 10,
	top    => 10,
	bottom => 10);

my $border = $structure.init();

$im.image_set_border($border);

my $scaled = $im.create_resized_image(
	location => (50, 60),
	scale    => (150, 100));
$scaled.context_set();



$im.image_set_format("png");
unlink("images/test_border.png") if "images/test_border.png".IO ~~ :e;
$im.save_image("images/test_border.png");
$im.free_image();

$loadedimage.context_set();
$im.free_image();

exit();
