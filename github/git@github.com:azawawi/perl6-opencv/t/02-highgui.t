use Test;
use lib 'lib';

plan 2;

use OpenCV::Highgui;

my $mat = imread("not-found.png");
ok($mat.defined, "Got an defined mat");
ok(!$mat.data, ".data is empty");