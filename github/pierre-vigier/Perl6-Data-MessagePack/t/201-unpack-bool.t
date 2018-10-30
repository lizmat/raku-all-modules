use v6;

use Test;
use Data::MessagePack;

plan 4;

nok Data::MessagePack::unpack( Blob.new( 0xc2 ) ), "Boolean False is unpacked correctly";
ok Data::MessagePack::unpack( Blob.new( 0xc2 ) ) ~~ Bool, "Boolean False is unpacked correctly";
ok Data::MessagePack::unpack( Blob.new( 0xc3 ) ), "Boolean True is unpacked correctly";
ok Data::MessagePack::unpack( Blob.new( 0xc3 ) ) ~~ Bool, "Boolean False is unpacked correctly";
