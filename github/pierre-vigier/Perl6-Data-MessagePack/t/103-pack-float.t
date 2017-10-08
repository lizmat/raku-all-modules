use v6;

use Test;
use Data::MessagePack;

plan 4;

ok Data::MessagePack::pack( 147.625 ) ~~ Blob.new(203,64,98,116,0,0,0,0,0), "Double packed correcly";
ok Data::MessagePack::pack( -147.625 ) ~~ Blob.new(203,192,98,116,0,0,0,0,0), "Negative double packed correcly";
ok Data::MessagePack::pack( 1.1 ) ~~ Blob.new(0xcb, 0x3f, 0xf1, 0x99, 0x99, 0x99, 0x99, 0x99, 0x9a), "Negative double packed correcly";

ok Data::MessagePack::pack( 147.00 ) ~~ Data::MessagePack::pack( 147 ), "Double with int value packed as int";
