use v6;

use Test;
use Data::MessagePack;

plan 8;

my $value;

$value = Data::MessagePack::unpack( Blob.new( 0xa3, 0x61, 0x62, 0x63 ) );
is $value, 'abc', "String unpacked correctly";
ok $value ~~ Str, "Type is correct";

$value = Data::MessagePack::unpack( Blob.new( 217,33,77,111,114,101,32,116,104,97,110,32,51,50,32,99,104,97,114,97,99,116,101,114,115,44,32,102,111,114,32,116,101,115,116) );
is $value, 'More than 32 characters, for test', "String unpacked correctly";
ok $value ~~ Str, "Type is correct";

$value = Data::MessagePack::unpack( Blob.new( 0xda, 0x01, 0x00, 0x61 xx (2**8) ) );
is $value, 'a' x 2**8, "String unpacked correctly";
ok $value ~~ Str, "Type is correct";

$value = Data::MessagePack::unpack( Blob.new( 0xdb, 0x00, 0x01, 0x00, 0x00, 0x62 xx (2**16) ) );
is $value, 'b' x 2**16, "String unpacked correctly";
ok $value ~~ Str, "Type is correct";
