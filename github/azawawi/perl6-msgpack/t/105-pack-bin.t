use v6;

use Test;
use MsgPack;

plan 3;

ok MsgPack::pack( Blob.new(1, 2, 3) ) ~~ any(Blob.new( 0xc4, 3, 1, 2, 3 ), Blob.new( 0xa3, 1, 2, 3 )), "Bin packed correctly";
ok MsgPack::pack( Blob.new(13 xx 2**8) ) ~~ any(Blob.new( 0xc5, 0x01, 0x00, 13 xx (2**8) ), Blob.new( 0xda, 0x01, 0x00, 13 xx (2**8))), "Bin packed correctly";
skip "TODO fix heap corruption bug"
#ok MsgPack::pack( Blob.new(14 xx 2**16) ) ~~ Blob.new( 0xc6, 0x00, 0x01, 0x00, 0x00, 14 xx (2**16)), "Bin packed correctly";
