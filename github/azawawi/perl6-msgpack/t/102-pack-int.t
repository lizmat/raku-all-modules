use v6;

use Test;
use MsgPack;

plan 19;

ok MsgPack::pack( 0) ~~ Blob.new(0x00), "Positive integer packed correctly";
ok MsgPack::pack( 1) ~~ Blob.new(0x01), "Positive integer packed correctly";
ok MsgPack::pack( 127) ~~ Blob.new(0x7f), "Positive integer packed correctly";
ok MsgPack::pack( 128) ~~ Blob.new(0xcc, 0x80), "Positive integer packed correctly";
ok MsgPack::pack( 255) ~~ Blob.new(0xcc, 0xff), "Positive integer packed correctly";
ok MsgPack::pack( 256) ~~ Blob.new(0xcd, 0x01, 0x00), "Positive integer packed correctly";
ok MsgPack::pack( 65535) ~~ Blob.new(0xcd, 0xff, 0xff), "Positive integer packed correctly";
ok MsgPack::pack( 65536) ~~ Blob.new(0xce, 0x00, 0x01, 0x00, 0x00), "Positive integer packed correctly";

# TODO Fix int tests
diag "TODO Fix positive integer tests";
# ok MsgPack::pack( 4294967295) ~~ Blob.new(0xce, 0xff, 0xff, 0xff, 0xff), "Positive integer packed correctly";
# ok MsgPack::pack( 4294967296) ~~ Blob.new(0xcf, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00), "Positive integer packed correctly";
# ok MsgPack::pack( 184467440737095) ~~ Blob.new(0xcf, 0x00, 0x00, 0xa7, 0xc5, 0xac, 0x47, 0x1b, 0x47), "Positive integer packed correctly";
# ok MsgPack::pack( 2**64 -1 ) ~~ Blob.new(0xcf, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff), "Positive integer packed correctly";
# throws-like { MsgPack::pack( 2**64 ); }, X::MsgPack::Packer;


ok MsgPack::pack( -1 ) ~~ Blob.new(0xff), "Negative integer packed correctly";
ok MsgPack::pack( -16 ) ~~ Blob.new(0xf0), "Negative integer packed correctly";
ok MsgPack::pack( -32 ) ~~ Blob.new(0xe0), "Negative integer packed correctly";
ok MsgPack::pack( -33 ) ~~ Blob.new(0xd0, 0xdf), "Negative integer packed correctly";
ok MsgPack::pack( -70 ) ~~ Blob.new(0xd0, 0xba), "Negative integer packed correctly";
ok MsgPack::pack( -127 ) ~~ Blob.new(0xd0, 0x81), "Negative integer packed correctly";
ok MsgPack::pack( -128 ) ~~ Blob.new(0xd0, 0x80), "Negative integer packed correctly";
ok MsgPack::pack( -129 ) ~~ Blob.new(0xd1, 0xff, 0x7f), "Negative integer packed correctly";
ok MsgPack::pack( -32768 ) ~~ Blob.new(0xd1, 0x80, 0x00), "Negative integer packed correctly";
ok MsgPack::pack( -32769 ) ~~ Blob.new(0xd2, 0xff, 0xff, 0x7f, 0xff), "Negative integer packed correctly";


ok MsgPack::pack( -2147483648 ) ~~ Blob.new(0xd2, 0x80, 0x00, 0x00, 0x00), "Negative integer packed correctly";
diag "TODO Fix negative integer tests";
# ok MsgPack::pack( -2147483649 ) ~~ Blob.new(0xd3, 0xff, 0xff, 0xff, 0xff, 0x7f, 0xff, 0xff, 0xff), "Negative integer packed correctly";
# ok MsgPack::pack( -9223372036854775808 ) ~~ Blob.new(0xd3, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00), "Negative integer packed correctly";
# todo "Implement X::MsgPack::Packer on limits validation";
# throws-like { MsgPack::pack( -9223372036854775809 ); }, X::MsgPack::Packer;
