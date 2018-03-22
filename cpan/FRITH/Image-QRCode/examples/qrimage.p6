#!/usr/bin/env perl6

# In order to run this program you need to install Image::PNG::Inflated
# zef install Image::PNG::Inflated

use lib 'lib';
use Image::QRCode;
use Image::QRCode :constants;
use Image::PNG::Inflated;

my $qrcode = Image::QRCode.new;
$qrcode.encode: 'https://perl6.org/';
my @data  := $qrcode.qrcode.data;
my $width := $qrcode.qrcode.width;
my @rows;
my @pixels;
loop (my $r = 0; $r < $width; $r++) {
  # for each data point in the row, get the least significant bit, flip it, multiply it by 255 (white),
  # duplicate each data point 10 times, then for each data point build a pixel: R + G + B + Alpha
  @rows[$r] = (((@data[$r * $width .. $r * $width + $width - 1] »+&» 1 »+^» 1) »*» 255)
    .map({ $_ xx 10 }))».map({ $_ xx 3, 255 }).flat;
  # make it a blob: a single row is now a sequence of bytes (blob8 is exported by Image::PNG::Inflated)
  my $blob = blob8.new(@rows[$r]);
  # repeat the blob 10 times
  @pixels[$r] = [~] $blob xx 10;
}
# connect all the rows in a single blob and build a 250x250 PNG image
my $img = to-png ([~] @pixels), 250, 250;
spurt 'qrcode.png', $img;
