use v6;

use Test;
use Data::MessagePack;

plan 27;

ok Data::MessagePack::pack( 0) ~~ Blob.new(0x00), "Positive integer packed correctly";
ok Data::MessagePack::pack( 1) ~~ Blob.new(0x01), "Positive integer packed correctly";
ok Data::MessagePack::pack( 127) ~~ Blob.new(0x7f), "Positive integer packed correctly";
ok Data::MessagePack::pack( 128) ~~ Blob.new(0xcc, 0x80), "Positive integer packed correctly";
ok Data::MessagePack::pack( 255) ~~ Blob.new(0xcc, 0xff), "Positive integer packed correctly";
ok Data::MessagePack::pack( 256) ~~ Blob.new(0xcd, 0x01, 0x00), "Positive integer packed correctly";
ok Data::MessagePack::pack( 65535) ~~ Blob.new(0xcd, 0xff, 0xff), "Positive integer packed correctly";
ok Data::MessagePack::pack( 65536) ~~ Blob.new(0xce, 0x00, 0x01, 0x00, 0x00), "Positive integer packed correctly";
ok Data::MessagePack::pack( 4294967295) ~~ Blob.new(0xce, 0xff, 0xff, 0xff, 0xff), "Positive integer packed correctly";
ok Data::MessagePack::pack( 4294967296) ~~ Blob.new(0xcf, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00), "Positive integer packed correctly";
ok Data::MessagePack::pack( 184467440737095) ~~ Blob.new(0xcf, 0x00, 0x00, 0xa7, 0xc5, 0xac, 0x47, 0x1b, 0x47), "Positive integer packed correctly";
ok Data::MessagePack::pack( 2**64 -1 ) ~~ Blob.new(0xcf, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff), "Positive integer packed correctly";
throws-like { Data::MessagePack::pack( 2**64 ); }, X::Data::MessagePack::Packer;

ok Data::MessagePack::pack( -1 ) ~~ Blob.new(0xff), "Negative integer packed correctly";
ok Data::MessagePack::pack( -16 ) ~~ Blob.new(0xf0), "Negative integer packed correctly";
ok Data::MessagePack::pack( -32 ) ~~ Blob.new(0xe0), "Negative integer packed correctly";
ok Data::MessagePack::pack( -33 ) ~~ Blob.new(0xd0, 0xdf), "Negative integer packed correctly";
ok Data::MessagePack::pack( -70 ) ~~ Blob.new(0xd0, 0xba), "Negative integer packed correctly";
ok Data::MessagePack::pack( -127 ) ~~ Blob.new(0xd0, 0x81), "Negative integer packed correctly";
ok Data::MessagePack::pack( -128 ) ~~ Blob.new(0xd0, 0x80), "Negative integer packed correctly";
ok Data::MessagePack::pack( -129 ) ~~ Blob.new(0xd1, 0xff, 0x7f), "Negative integer packed correctly";
ok Data::MessagePack::pack( -32768 ) ~~ Blob.new(0xd1, 0x80, 0x00), "Negative integer packed correctly";
ok Data::MessagePack::pack( -32769 ) ~~ Blob.new(0xd2, 0xff, 0xff, 0x7f, 0xff), "Negative integer packed correctly";
ok Data::MessagePack::pack( -2147483648 ) ~~ Blob.new(0xd2, 0x80, 0x00, 0x00, 0x00), "Negative integer packed correctly";
ok Data::MessagePack::pack( -2147483649 ) ~~ Blob.new(0xd3, 0xff, 0xff, 0xff, 0xff, 0x7f, 0xff, 0xff, 0xff), "Negative integer packed correctly";
ok Data::MessagePack::pack( -9223372036854775808 ) ~~ Blob.new(0xd3, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00), "Negative integer packed correctly";
throws-like { Data::MessagePack::pack( -9223372036854775809 ); }, X::Data::MessagePack::Packer;
