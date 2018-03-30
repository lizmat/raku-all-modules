#!/usr/bin/env perl6

use Test;
use lib 'lib';
use Image::QRCode;
use Image::QRCode :constants;

my $ver;
try {
  $ver = QRcode_APIVersionString;
  CATCH {
    default {
      $ver = '0.0.0';
    }
  }
}
my Version $version .= new($ver);

my QRinput $qrinput = QRinput_new;
is $qrinput.WHAT, QRinput, 'QRinput_new';
my int32 $ret;
subtest {
  is QRinput_getVersion($qrinput), 0, 'QRinput_getVersion';
  is QRinput_setVersion($qrinput, 1), 0, 'QRinput_setVersion with valid version';
  is QRinput_getVersion($qrinput), 1, 'QRinput_setVersion successful';
  $ret = QRinput_setVersion($qrinput, 41);
  ok $ret == -1, 'QRinput_setVersion with invalid version';
}, 'set/get version';
QRinput_free($qrinput);
ok QRinput_getVersion($qrinput) != 1, 'QRinput_free';
my QRinput $qrinput2 = QRinput_new2(2, QR_ECLEVEL_L);
is $qrinput2.WHAT, QRinput, 'QRinput_new2';
is QRinput_getVersion($qrinput2), 2, 'version check on QRinput_new2';
is QRinput_setErrorCorrectionLevel($qrinput2, QR_ECLEVEL_M), 0, 'set error correction level';
if $version ~~ v3.2.1+ {
  my QRinput $qrinputMQR = QRinput_newMQR(3, QR_ECLEVEL_L);
  is $qrinputMQR.WHAT, QRinput, 'QRinput_newMQR';
  is QRinput_getVersion($qrinputMQR), 3, 'version check on QRinput_newMQR';
  $ret = QRinput_setErrorCorrectionLevel($qrinputMQR, QR_ECLEVEL_L);
  ok $ret == -1, 'correction level cannot be set on MQR';
  is QRinput_getErrorCorrectionLevel($qrinputMQR), +QR_ECLEVEL_L, 'get error correction level';
} else {
  skip 'Pre v3.2.1 libqrencode', 4;
}
subtest {
  is QRinput_setVersionAndErrorCorrectionLevel($qrinput2, 10, QR_ECLEVEL_M), 0, 'call function';
  is QRinput_getVersion($qrinput2), 10, 'check version';
  is QRinput_getErrorCorrectionLevel($qrinput2), +QR_ECLEVEL_M, 'check error correction level';
}, 'set/get version and error correction level';

done-testing;
