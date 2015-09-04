use v6;

use Test;

plan 6;

use GD;

ok 1, 'GD is loaded successfully';

my $image = GD::Image.new(200, 200);
isa_ok $image, GD::Image, "Successfully created a GD::Image";

my $black = $image.colorAllocate(
    red   => 0,
    green => 0,
    blue  => 0);

my $white = $image.colorAllocate("#ffffff");

ok 1, 'Colors created successfully';

$image.rectangle(
    location => (10, 10),
    size     => (100, 100),
    fill     => True,
    color    => $white);

$image.line(
    start => (10, 10),
    end   => (190, 190),
    color => $black);

ok 1, 'rectangle and line did not die';

"t/test.png".IO.unlink;

my $png_fh = $image.open("t/test.png", "wb");

$image.output($png_fh, GD_PNG);

$png_fh.close;

ok "t/test.png".IO.e, "Some sort of test.png written";

$image.destroy();

ok 1, 'Survived $image.destroy';
