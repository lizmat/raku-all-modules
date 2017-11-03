use v6;

use Test;
use MsgPack;

plan 2;

ok MsgPack::pack( False ) ~~ Blob.new( 0xc2 ), "Boolean False is packed correctly";
ok MsgPack::pack( True )  ~~ Blob.new( 0xc3 ), "Boolean True is packed correctly";
