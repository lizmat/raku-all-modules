use v6;
use Test;
use lib <t lib>;

use common;

use Image::Resize;

plan 3;

my $camelia = "t/images/500px-Camelia.png";
my $width = 500;
my $height = 366;

# Test no resample
{
    my $resample = tmp-file("png");
    my $resize = tmp-file("png");

    resize-image($camelia, $resample, 0.25);
    resize-image($camelia, $resize, 0.25, :no-resample);

    isnt $resample.IO.s, $resize.IO.s, "Resize and resample differ";
}

# Test jpeg quality
{
    my $bad-quality = tmp-file("jpg");
    my $default-quality = tmp-file("jpeg");

    resize-image($camelia, $default-quality, 2.0);
    resize-image($camelia, $bad-quality, 2.0, :jpeg-quality(5));

    ok $bad-quality.IO.s < $default-quality.IO.s, "Bad quality JPEG takes less space";
    ok $bad-quality.IO.s > 0 && $bad-quality.IO.s > 0, "... and they contain data";
}



done;
# vim: ft=perl6
