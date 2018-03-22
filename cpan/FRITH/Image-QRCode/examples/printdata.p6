#!/usr/bin/env perl6

use lib 'lib';
use Image::QRCode;

my $code = Image::QRCode.new.encode('https://perl6.org/');
my $dim = $code.qrcode.width;
my @array2D[$dim;$dim] = $code.get-data(2);
say @array2D.shape;
say @array2D;
my @array1D = $code.get-data(1);
say @array1D;
