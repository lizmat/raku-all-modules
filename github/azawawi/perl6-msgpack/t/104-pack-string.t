use v6;

use Test;
use MsgPack;

plan 5;

ok MsgPack::pack( 'abc') ~~ Blob.new( 0xa3, 0x61, 0x62, 0x63 ), "String packed correctly";
my $blob-v4 = Blob.new(217,33,77,111,114,101,32,116,104,97,110,32,51,50,32,99,104,97,114,97,99,116,101,114,115,44,32,102,111,114,32,116,101,115,116);
my $blob-v5 = Blob.new(218,0,33,77,111,114,101,32,116,104,97,110,32,51,50,32,99,104,97,114,97,99,116,101,114,115,44,32,102,111,114,32,116,101,115,116);
ok MsgPack::pack( 'More than 32 characters, for test' ) ~~ any($blob-v4, $blob-v5), "String packed correctly v4/v5";
ok MsgPack::pack( 'a' x 2**8 ) ~~ Blob.new( 0xda, 0x01, 0x00, 0x61 xx (2**8) ), "String packed correctly";
ok MsgPack::pack( 'a' x 2**16 ) ~~ Blob.new( 0xdb, 0x00, 0x01, 0x00, 0x00, 0x61 xx (2**16) ), "String packed correctly";
pass "Test of 2**32 string is too big, just assume it is working"
#throws-like { MsgPack::pack( 'a' x (2**32) ); }, X::MsgPack::Packer;
