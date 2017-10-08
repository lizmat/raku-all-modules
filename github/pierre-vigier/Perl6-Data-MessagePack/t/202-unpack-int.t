use v6;

use Test;
use Data::MessagePack;

plan 40;

my $value;

$value = Data::MessagePack::unpack( Blob.new(0x00) );
ok $value == 0, "Positive integer unpacked correctly";
ok $value ~~ Int, "Type is correct";

$value = Data::MessagePack::unpack( Blob.new(0x7f) );
ok $value == 127, "Positive integer unpacked correctly";
ok $value ~~ Int, "Type is correct";

$value = Data::MessagePack::unpack( Blob.new(0xcc, 0xff) );
ok $value == 255, "Positive integer unpacked correctly";
ok $value ~~ Int, "Type is correct";

$value = Data::MessagePack::unpack( Blob.new(0xcd, 0x01, 0x00) );
ok $value == 256, "Positive integer unpacked correclty";
ok $value ~~ Int, "Type is correct";

$value = Data::MessagePack::unpack( Blob.new(0xcd, 0xff, 0xff) );
ok $value == 65535, "Positive integer unpacked correclty";
ok $value ~~ Int, "Type is correct";

$value = Data::MessagePack::unpack( Blob.new(0xce, 0x00, 0x01, 0x00, 0x00) );
ok $value == 65536, "Positive integer unpacked correclty";
ok $value ~~ Int, "Type is correct";

$value = Data::MessagePack::unpack( Blob.new(0xce, 0xff, 0xff, 0xff, 0xff) );
ok $value == 4294967295, "Positive integer unpacked correclty";
ok $value ~~ Int, "Type is correct";

$value = Data::MessagePack::unpack( Blob.new(0xcf, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00) );
ok $value == 4294967296, "Positive integer unpacked correclty";
ok $value ~~ Int, "Type is correct";

$value = Data::MessagePack::unpack( Blob.new(0xcf, 0x00, 0x00, 0xa7, 0xc5, 0xac, 0x47, 0x1b, 0x47) );
ok $value == 184467440737095, "Positive integer unpacked correclty";
ok $value ~~ Int, "Type is correct";

$value = Data::MessagePack::unpack( Blob.new(0xcf, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff) );
ok $value == (2**64 -1), "Positive integer unpacked correclty";
ok $value ~~ Int, "Type is correct";

$value = Data::MessagePack::unpack( Blob.new(0xf0) );
ok $value == -16, "Negative integer unpacked correctly";
ok $value ~~ Int, "Type is correct";

$value = Data::MessagePack::unpack( Blob.new(0xe0) );
ok $value == -32, "Negative integer unpacked correctly";
ok $value ~~ Int, "Type is correct";

$value = Data::MessagePack::unpack( Blob.new(0xd0, 0xdf) );
ok $value == -33, "Negative integer unpacked correclty";
ok $value ~~ Int, "Type is correct";

$value = Data::MessagePack::unpack( Blob.new(0xd0, 0x80) );
ok $value == -128, "Negative integer unpacked correclty";
ok $value ~~ Int, "Type is correct";

$value = Data::MessagePack::unpack( Blob.new(0xd1, 0xff, 0x7f) );
ok $value == -129, "Negative integer unpacked correclty";
ok $value ~~ Int, "Type is correct";

$value = Data::MessagePack::unpack( Blob.new(0xd1, 0x80, 0x00) );
ok $value == -32768, "Negative integer unpacked correclty";
ok $value ~~ Int, "Type is correct";

$value = Data::MessagePack::unpack( Blob.new(0xd2, 0xff, 0xff, 0x7f, 0xff) );
ok $value == -32769, "Negative integer unpacked correclty";
ok $value ~~ Int, "Type is correct";

$value = Data::MessagePack::unpack( Blob.new(0xd2, 0x80, 0x00, 0x00, 0x00) );
ok $value == -2147483648, "Negative integer unpacked correclty";
ok $value ~~ Int, "Type is correct";

$value = Data::MessagePack::unpack( Blob.new(0xd3, 0xff, 0xff, 0xff, 0xff, 0x7f, 0xff, 0xff, 0xff) );
ok $value == -2147483649, "Negative integer unpacked correclty";
ok $value ~~ Int, "Type is correct";

$value = Data::MessagePack::unpack( Blob.new(0xd3, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00) );
ok $value == -9223372036854775808, "Negative integer unpacked correclty";
ok $value ~~ Int, "Type is correct";
