use v6;

use Test;
use MsgPack;

plan 7;

my @value = Any, Int, Bool, Str, Blob, Numeric;

for @value -> $val {
    ok MsgPack::pack( $val ) ~~ Blob.new( 0xc0 ), "Undefined is packed correctly";
}

my $var;
ok MsgPack::pack( $var ) ~~ Blob.new( 0xc0 ), "Undefined is packed correctly";
