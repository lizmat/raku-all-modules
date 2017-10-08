use v6;
use Test;
use lib <t lib>;

use Image::Resize;
use common;

plan 2;

my $camelia = "t/images/500px-Camelia.png";
my $width = 500;
my $height = 366;

my $width-img = tmp-file('png');
my $height-img = tmp-file('png');

my ($x, $y);

scale-to-width($camelia, $width-img, 100);
($x, $y) = get-png-size($width-img);
is $x, 100, 'width is 100';

scale-to-height($camelia, $height-img, 100);
 ($x, $y) = get-png-size($height-img);
is $y, 100, 'height is 100';

done-testing;
# vim: ft=perl6
