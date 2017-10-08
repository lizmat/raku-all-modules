use v6;

use Test;
use Data::MessagePack;

plan 8;

#float
my $value;

$value = Data::MessagePack::unpack( Blob.new( 0xca, 0x42, 0x02, 0x80, 0x00 ) );
ok $value == 32.625, "Float decoded correctly";
ok $value ~~ Numeric, "Type is correct";

$value = Data::MessagePack::unpack( Blob.new( 0xca, 0x3F, 0x8C, 0xCC, 0xCD ) );
{
    my $*TOLERANCE = .000001;
    ok $value =~= 1.1, "Float decoded correctly";
}
ok $value ~~ Numeric, "Type is correct";

#double
$value = Data::MessagePack::unpack( Blob.new(0xcb, 192,98,116,0,0,0,0,0 ) );
ok $value == -147.625, "Float decoded correctly";
ok $value ~~ Numeric, "Type is correct";

$value = Data::MessagePack::unpack( Blob.new(0xcb, 0x3f, 0xf1, 0x99, 0x99, 0x99, 0x99, 0x99, 0x9a) );
{
    my $*TOLERANCE = 10**-15;
    ok $value =~= 1.1, "Float decoded correctly";
}
ok $value ~~ Numeric, "Type is correct";
