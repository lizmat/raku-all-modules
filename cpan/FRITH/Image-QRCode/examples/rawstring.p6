#!/usr/bin/env perl6

# Set your terminal colors to white background with black characters

use lib 'lib';
use Image::QRCode;
use Image::QRCode :constants;

my QRcode $qrcode = QRcode_encodeString(@*ARGS[0], 0, QR_ECLEVEL_L, QR_MODE_8, 1);
my @data := $qrcode.data;
my $w := $qrcode.width;
(@data[$_ * $w .. $_ * $w + $w - 1] »+&» 1)
  .map({ $_ xx 2 })
  .flat
  .join
  .trans('1' => "\c[FULL BLOCK]", '0' => ' ')
  .say
    for ^$w;
