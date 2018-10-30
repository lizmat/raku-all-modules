use v6;

use Test;
use Data::MessagePack;

plan 3;

my $value;

$value = Data::MessagePack::unpack( Blob.new( 0xc4, 3, 1, 2, 3 ) );
ok $value ~~ Blob.new(1, 2, 3), "Binary unpacked correctly";

$value = Data::MessagePack::unpack( Blob.new( 0xc5, 0x01, 0x00, 13 xx (2**8) ) );
ok $value ~~ Blob.new(13 xx 2**8), "Binary unpacked correctly";

$value = Data::MessagePack::unpack( Blob.new( 0xc6, 0x00, 0x01, 0x00, 0x00, 14 xx (2**16) ) );
ok $value ~~ Blob.new(14 xx 2**16), "Binary unpacked correctly";
