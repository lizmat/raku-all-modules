use v6;

use Test;
use MsgPack;

plan 1;

unless ?%*ENV<EXPERIMENTAL> {
    skip-rest "Skipping experimental tests";
    exit;
}

ok MsgPack::unpack( Blob.new( 0xc0 ) ) ~~ Any, "Undefined is packed correctly";
