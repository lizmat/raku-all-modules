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

my QRcode $qrcodestr = QRcode_encodeString('123', 0, QR_ECLEVEL_L, QR_MODE_8, 0);
my uint8 @data := $qrcodestr.data;
is @data[^$qrcodestr.width] «+&» 1,
  (1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1),
  'qrcode from string';
my QRcode $qrcode8bit = QRcode_encodeString8bit('123', 0, QR_ECLEVEL_L);
my uint8 @data8bit := $qrcodestr.data;
is @data8bit[^$qrcode8bit.width] «+&» 1,
  (1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1),
  'qrcode from 8-bit data';
if $version ~~ v3.2.1+ {
  my QRcode $qrcodemqr = QRcode_encodeStringMQR('123', 1, QR_ECLEVEL_L, QR_MODE_8, 0);
  my uint8 @datamqr := $qrcodemqr.data;
  is @datamqr[^$qrcodemqr.width] «+&» 1,
    (1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1),
    'MQR from string';
} else {
  skip 'Pre v3.2.1 libqrencode', 1;
}
my QRcode $qrcodemqr8bit = QRcode_encodeString8bitMQR('123', 3, QR_ECLEVEL_L);
my uint8 @datamqr8bit := $qrcodemqr8bit.data;
is @datamqr8bit[^$qrcodemqr8bit.width] «+&» 1,
  (1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1),
  'MQR from 8-bit data';
my QRcode $qrcodedata = QRcode_encodeData(3, '123', 3, QR_ECLEVEL_L);
my uint8 @datadata := $qrcodedata.data;
is @datadata[^$qrcodedata.width] «+&» 1,
  (1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1),
  'qrcode from data';
if $version ~~ v3.2.1+ {
  my QRcode $mqrdata = QRcode_encodeDataMQR(3, '123', 3, QR_ECLEVEL_L);
  my uint8 @datamqr1 := $mqrdata.data;
  is @datamqr1[^$mqrdata.width] «+&» 1,
    (1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1),
    'qrcode from data';
} else {
  skip 'Pre v3.2.1 libqrencode', 1;
}
my QRinput $qrinput = QRinput_new;
is QRinput_check(QR_MODE_NUM, 3, '123'), 0, 'check valid data before appending';
my int32 $res = QRinput_check(QR_MODE_NUM, 3, 'a123');
is $res, -1, 'check invalid data before appending';
is QRinput_append($qrinput, QR_MODE_NUM, 3, '123'), 0, 'append data';
if $version ~~ v3.2.1+ {
  is QRinput_appendECIheader($qrinput, 10000), 0, 'append ECI header';
} else {
  skip 'Pre v3.2.1 libqrencode', 1;
}
is QRinput_setFNC1First($qrinput), 0, 'QRinput_setFNC1First';
is QRinput_setFNC1Second($qrinput, 1), 0, 'QRinput_setFNC1Second';
my QRcode $qrcodeqrinput = QRcode_encodeInput($qrinput);
my uint8 @dataqrinput := $qrcodeqrinput.data;
is @dataqrinput[^$qrcodeqrinput.width] «+&» 1,
  (1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1),
  'qrcode from QRinput';
my QRinput_Struct $qrstruct = QRinput_splitQRinputToStruct($qrinput);
ok ($qrstruct.defined && $qrstruct.WHAT ~~ QRinput_Struct), 'QRinput_splitQRinputToStruct';
subtest {
  my QRinput $qrinput = QRinput_new;
  QRinput_append($qrinput, QR_MODE_NUM, 3, '123');
  my QRinput_Struct $qrstruct = QRinput_Struct_new;
  ok ($qrstruct.defined && $qrstruct.WHAT ~~ QRinput_Struct), 'QRinput_Struct_new';
  $res = QRinput_Struct_appendInput($qrstruct, $qrinput);
  ok $res == 1, 'append one object';
  is QRinput_Struct_insertStructuredAppendHeaders($qrstruct), 0, 'QRinput_Struct_insertStructuredAppendHeaders';
  my QRcode_List $qrlist = QRcode_encodeInputStructured($qrstruct);
  ok ($qrlist.defined && $qrlist.WHAT ~~ QRcode_List), 'call QRcode_encodeInputStructured';
  is QRcode_List_size($qrlist), 1, 'list size';
  my $entry = $qrlist;
  while $entry {
    my QRcode $qrcode = $entry.code;
    $entry = $entry.next;
    is $qrcode.version, 1, 'qrcode version';
    is $qrcode.width, 21, 'qrcode width';
    my uint8 @data := $qrcode.data;
    if QRcode_APIVersionString() eq '3.4.4' {
      is @data[^$qrcode.width] «+&» 1,
        (1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1),
        'qrcode data';
    } else {
      skip 'qrcode data', 1;
    }
  }
}, 'encode a QRinput_struct';
subtest {
  my QRinput $qrinput = QRinput_new;
  QRinput_append($qrinput, QR_MODE_NUM, 3, '123');
  my QRcode_List $qrlist = QRcode_encodeStringStructured('123', 1, QR_ECLEVEL_L, QR_MODE_8, 0);
  ok ($qrlist.defined && $qrlist.WHAT ~~ QRcode_List), 'call QRcode_encodeStringStructured';
  is QRcode_List_size($qrlist), 1, 'list size';
  my $entry = $qrlist;
  while $entry {
    my QRcode $qrcode = $entry.code;
    $entry = $entry.next;
    is $qrcode.version, 1, 'qrcode version';
    is $qrcode.width, 21, 'qrcode width';
    my uint8 @data := $qrcode.data;
    if QRcode_APIVersionString() eq '3.4.4' {
      is @data[^$qrcode.width] «+&» 1,
        (1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1),
        'qrcode data';
    } else {
      skip 'qrcode data', 1;
    }
  }
}, 'encode a string (structured)';
subtest {
  my QRinput $qrinput = QRinput_new;
  QRinput_append($qrinput, QR_MODE_NUM, 3, '123');
  my QRcode_List $qrlist = QRcode_encodeString8bitStructured('123', 1, QR_ECLEVEL_L);
  ok ($qrlist.defined && $qrlist.WHAT ~~ QRcode_List), 'call QRcode_encodeString8bitStructured';
  is QRcode_List_size($qrlist), 1, 'list size';
  my $entry = $qrlist;
  while $entry {
    my QRcode $qrcode = $entry.code;
    $entry = $entry.next;
    is $qrcode.version, 1, 'qrcode version';
    is $qrcode.width, 21, 'qrcode width';
    my uint8 @data := $qrcode.data;
    if QRcode_APIVersionString() eq '3.4.4' {
      is @data[^$qrcode.width] «+&» 1,
        (1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 0, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1),
        'qrcode data';
    } else {
      skip 'qrcode data', 1;
    }
  }
}, 'encode from 8-bit string (structured)';
subtest {
  my QRinput $qrinput = QRinput_new;
  QRinput_append($qrinput, QR_MODE_NUM, 3, '123');
  my QRcode_List $qrlist = QRcode_encodeDataStructured(3, '123', 3, QR_ECLEVEL_L);
  ok ($qrlist.defined && $qrlist.WHAT ~~ QRcode_List), 'call QRcode_encodeDataStructured';
  is QRcode_List_size($qrlist), 1, 'list size';
  my $entry = $qrlist;
  while $entry {
    my QRcode $qrcode = $entry.code;
    $entry = $entry.next;
    is $qrcode.version, 3, 'qrcode version';
    is $qrcode.width, 29, 'qrcode width';
    my uint8 @data := $qrcode.data;
    if QRcode_APIVersionString() eq '3.4.4' {
      is @data[^$qrcode.width] «+&» 1,
        (1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1),
        'qrcode data';
    } else {
      skip 'qrcode data', 1;
    }
  }
}, 'encode data (structured)';
done-testing;
