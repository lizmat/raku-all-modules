#!/usr/bin/env perl6

# Set your terminal colors to white background with black characters

use lib 'lib';
use Image::QRCode;
use Image::QRCode :constants;

my $qrinput = QRinput_new;
QRinput_append($qrinput, QR_MODE_8, @*ARGS[0].chars, @*ARGS[0]);
my $qrstruct = QRinput_Struct_new;
QRinput_Struct_appendInput($qrstruct, $qrinput);
my $qrlist = QRcode_encodeInputStructured($qrstruct);
my $entry = $qrlist;
while $entry {
  my $qrcode = $entry.code;
  $entry = $entry.next;
  my @data := $qrcode.data;
  my $w := $qrcode.width;
  (@data[$_ * $w .. $_ * $w + $w - 1] »+&» 1)
    .map({ $_ xx 2 })
    .flat
    .join
    .trans('1' => "\c[FULL BLOCK]", '0' => ' ')
    .say
      for ^$w;
}
