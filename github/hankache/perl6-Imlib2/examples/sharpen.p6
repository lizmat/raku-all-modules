use Imlib2;

my $radius = prompt("How much you want to sharpen the image? (0..128): ");

my $im = Imlib2.new();
my $loadedimage = $im.load_image("images/camelia-logo.jpg");
exit() unless $loadedimage;

$loadedimage.context_set();

$im.image_sharpen($radius.Int);

$im.image_set_format("png");
unlink("images/test_sharpen.png") if "images/test_sharpen.png".IO ~~ :e;
$im.save_image("images/test_sharpen.png");
$im.free_image();

exit();
