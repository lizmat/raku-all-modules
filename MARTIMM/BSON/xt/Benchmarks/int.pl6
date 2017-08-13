#!/usr/bin/env perl6

use v6;
use NativeCall;
use BSON;
use Bench;

my Int $i1 = 123456789;
my Buf $bi1 = encode-int64($i1);
my Buf $bi2;
my Int $i2;

my $b = Bench.new;
$b.timethese(
  3000, {
    '32 bit integer encode' => sub { $bi2 = encode-int32($i1); },
    '32 bit integer decode' => sub { $i2 = decode-int32( $bi1, 0); },
    '64 bit integer encode' => sub { $bi2 = encode-int64($i1); },
    '64 bit integer decode' => sub { $i2 = decode-int64( $bi1, 0); },
#    '32 bit native integer decode' => sub { $i2 = decode-int32-native( $bi1, 0); },
#    '64 bit native integer decode' => sub { $i2 = decode-int64-native( $bi1, 0); },
  }
);

say "I = $i2, bi2 = ", $bi2.perl;

#------------------------------------------------------------------------------
# decode to Int from buf little endian
sub decode-int32-native ( Buf:D $b, Int:D $index --> Int ) is export {

  state $little-endian = little-endian();

  my CArray[uint8] $ble;
  if $little-endian {
    $ble .= new($b.subbuf( $index, 4));
  }

  else {
    $ble .= new($b.subbuf( $index, 4).reverse);
  }

  nativecast( CArray[int32], $ble)[0];
}

#------------------------------------------------------------------------------
# decode to Int from buf little endian
sub decode-int64-native ( Buf:D $b, Int:D $index --> Int ) is export {

  state $little-endian = little-endian();

  my CArray[uint8] $ble;
  if $little-endian {
    $ble .= new($b.subbuf( $index, 8));
  }

  else {
    $ble .= new($b.subbuf( $index, 8).reverse);
  }

  nativecast( CArray[int64], $ble)[0];
}
