use v6;

use Test;
use Data::MessagePack;

plan 7;

my @value = Any, Int, Bool, Str, Blob, Numeric;

for @value -> $val {
    ok Data::MessagePack::pack( $val ) ~~ Blob.new( 0xc0 ), "Undefined is packed correctly";
}

my $var;
ok Data::MessagePack::pack( $var ) ~~ Blob.new( 0xc0 ), "Undefined is packed correctly";
