use v6;

use Test;
use MsgPack;

plan 3;

my $value;

$value = MsgPack::unpack( Blob.new( 0xc4, 3, 1, 2, 3 ) );
ok $value ~~ Blob.new(1, 2, 3), "Binary unpacked correctly";

$value = MsgPack::unpack( Blob.new( 0xc5, 0x01, 0x00, 13 xx (2**8) ) );
ok $value ~~ Blob.new(13 xx 2**8), "Binary unpacked correctly";

$value = MsgPack::unpack( Blob.new( 0xc6, 0x00, 0x01, 0x00, 0x00, 14 xx (2**16) ) );
ok $value ~~ Blob.new(14 xx 2**16), "Binary unpacked correctly";
