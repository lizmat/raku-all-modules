use v6;
use Test;

use lib 'lib';

use GD::Raw;
plan 7;

# Create image
{
        my $img = gdImageCreateTrueColor(64, 64);
        ok $img, "Created an image";
        gdImageDestroy($img);
}

my $tmp-path = $*TMPDIR.child("gd-raw-tmpimg");

# Create and load a png
{
        my $img = gdImageCreateTrueColor(64, 64);
        my $fh = fopen($tmp-path.Str, "wb");
        ok $fh, "Open image for writing";
        lives-ok { gdImagePng($img, $fh) }, "Wrote png";
        fclose($fh);
        gdImageDestroy($img);


        $fh = fopen($tmp-path.Str, "rb");
        ok $fh, "Open png image for reading";
        $img = gdImageCreateFromPng($fh);
        ok $img, "Loaded png";
        is gdImageSX($img), 64, "Image is 64 pixels in x";
        is gdImageSY($img), 64, "Image is 64 pixels in y";
        gdImageDestroy($img);
}

done-testing;

try { unlink $tmp-path.Str }
