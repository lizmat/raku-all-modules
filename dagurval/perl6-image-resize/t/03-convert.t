use v6;
use Test;
use lib <t lib>;

use Image::Resize;
use common;

plan 2;

my $camelia = "t/images/500px-Camelia.png";
my $width = 500;
my $height = 366;

# Back and forth between formats.
{
  for <gif jpg> -> $ext {
          my $ext-img = tmp-file($ext);
          my $png-img = tmp-file("png");
          resize-image($camelia, $ext-img, 16, 16);
          resize-image($ext-img, $png-img, 1.0);

          my ($x, $y) = get-png-size($png-img);
          ok $x == 16 && $y == 16, "png -> $ext -> png";
  }
}

done;
# vim: ft=perl6
