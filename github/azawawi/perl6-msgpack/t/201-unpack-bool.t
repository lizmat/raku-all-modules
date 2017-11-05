use v6;

use Test;
use MsgPack;

plan 4;

unless ?%*ENV<EXPERIMENTAL> {
    skip-rest "Skipping experimental tests";
    exit;
}

nok MsgPack::unpack( Blob.new( 0xc2 ) ), "Boolean False is unpacked correctly";
ok MsgPack::unpack( Blob.new( 0xc2 ) ) ~~ Bool, "Boolean False is unpacked correctly";
ok MsgPack::unpack( Blob.new( 0xc3 ) ), "Boolean True is unpacked correctly";
ok MsgPack::unpack( Blob.new( 0xc3 ) ) ~~ Bool, "Boolean False is unpacked correctly";
