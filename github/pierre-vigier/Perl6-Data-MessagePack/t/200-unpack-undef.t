use v6;

use Test;
use Data::MessagePack;

plan 1;

ok Data::MessagePack::unpack( Blob.new( 0xc0 ) ) ~~ Any, "Undefined is packed correctly";
