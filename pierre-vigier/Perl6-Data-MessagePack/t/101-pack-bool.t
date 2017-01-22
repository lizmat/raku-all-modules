use v6;

use Test;
use Data::MessagePack;

plan 2;

ok Data::MessagePack::pack( False ) ~~ Blob.new( 0xc2 ), "Boolean False is packed correctly";
ok Data::MessagePack::pack( True ) ~~ Blob.new( 0xc3 ), "Boolean True is packed correctly";
