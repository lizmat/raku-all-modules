use Imlib2;

my $radius = prompt("How much value to blur the image? (0..128): ");

my $im = Imlib2.new();
my $loadedimage = $im.load_image("images/camelia-logo.jpg");
exit() unless $loadedimage;

$loadedimage.context_set();

$im.image_blur($radius.Int);

$im.image_set_format("png");
unlink("images/test_blur.png") if "images/test_blur.png".IO ~~ :e;
$im.save_image("images/test_blur.png");
$im.free_image();

exit();
