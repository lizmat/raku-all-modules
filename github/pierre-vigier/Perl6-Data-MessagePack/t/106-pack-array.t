use v6;

use Test;
use Data::MessagePack;

plan 10;

ok Data::MessagePack::pack( [] ) ~~ Blob.new( 0x90 ), "Array packed correctly";
ok Data::MessagePack::pack( () ) ~~ Blob.new( 0x90 ), "Array packed correctly";
ok Data::MessagePack::pack( [[],] ) ~~ Blob.new( 0x91, 0x90 ), "Array packed correctly";
ok Data::MessagePack::pack( (1,2,3) ) ~~ Blob.new( 0x93, 1,2,3), "Array packed correctly";
ok Data::MessagePack::pack( (Any, False, True) ) ~~ Blob.new( 0x93, 0xc0,0xc2,0xc3), "Array packed correctly";

ok Data::MessagePack::pack(["", "a", "bc", "def"]) ~~ Blob.new(148,160,161,97,162,98,99,163,100,101,102), "Array packed correctly";
ok Data::MessagePack::pack( [1.1,-2.2,3.3,-4.4] ) ~~ Blob.new(148,203,63,241,153,153,153,153,153,154,203,192,1,153,153,153,153,153,154,203,64,10,102,102,102,102,102,102,203,192,17,153,153,153,153,153,154), "Array packed correctly";
ok Data::MessagePack::pack( [{},{ a=> 2},3] ) ~~ Blob.new(147,128,129,161,97,2,3), "Array packed correctly";

ok Data::MessagePack::pack( [ 1 xx 16 ] ) ~~ Blob.new( 0xdc, 0x00, 0x10, 0x01 xx 16 ), "Array packed correctly";
ok Data::MessagePack::pack( [ 'a' xx 16 ] ) ~~ Blob.new( 0xdc, 0x00, 0x10, (0xa1, 0x61) xx 16 ), "Array packed correctly";
