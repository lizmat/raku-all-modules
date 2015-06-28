use v6;
use Test;

BEGIN { @*INC.unshift('lib') }
BEGIN { @*INC.unshift('t') }

use common;
use Image::Resize;

plan 6;

my $camelia = "t/images/500px-Camelia.png";
my $width = 500;
my $height = 366;

#plan 11;

# Test factor
{
    my $half = tmp-file("png");
    my $double = tmp-file("png");
    resize-image($camelia, $half, 0.5);
    resize-image($camelia, $double, 2.0);


    my ($x, $y) = get-png-size($half);
    is $x, $width / 2, "Reduced image x to 0.5";
    is $y, $height / 2, "Reduced image y to 0.5";

    ($x, $y) = get-png-size($double);
    is $x, $width * 2, "Doubled image x";
    is $y, $height * 2, "Doubled image y";
}

# Test explicit size
{
    my $sixfour = tmp-file("png");
    resize-image($camelia, $sixfour, 64, 64);
    my ($x, $y) = get-png-size($sixfour);

    is $x, "64", "Resized x to 64";
    is $y, "64", "Resized y to 64";
}

done;

# vim: ft=perl6
