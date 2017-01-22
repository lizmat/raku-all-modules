use v6;

use Test;
use Data::MessagePack;

plan 3;

ok Data::MessagePack::pack( Blob.new(1, 2, 3) ) ~~ Blob.new( 0xc4, 3, 1, 2, 3 ), "Bin packed correctly";
ok Data::MessagePack::pack( Blob.new(13 xx 2**8) ) ~~ Blob.new( 0xc5, 0x01, 0x00, 13 xx (2**8) ), "Bin packed correctly";
ok Data::MessagePack::pack( Blob.new(14 xx 2**16) ) ~~ Blob.new( 0xc6, 0x00, 0x01, 0x00, 0x00, 14 xx (2**16) ), "Bin packed correctly";
