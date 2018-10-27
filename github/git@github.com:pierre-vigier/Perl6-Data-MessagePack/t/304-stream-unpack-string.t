use v6;
use Test;
use Data::MessagePack::StreamingUnpacker;

plan 4;

my @to_send = 0xa3, 0x61, 0x62, 0x63,
 217,33,77,111,114,101,32,116,104,97,110,32,51,50,32,99,104,97,114,97,99,116,101,114,115,44,32,102,111,114,32,116,101,115,116,
 0xda, 0x01, 0x00, |(0x61 xx (2**8)),
 0xdb, 0x00, 0x01, 0x00, 0x00, |(0x62 xx (2**16))
;

my @expected = 'abc',
 'More than 32 characters, for test',
 'a' x 2**8,
 'b' x 2**16
 ;

my $supplier = Supplier.new;

my $s = Data::MessagePack::StreamingUnpacker.new( source => $supplier.Supply );
my $unpacked = $s.Supply();

$unpacked.tap( -> $v {
    my $expected = @expected.shift;
    ok $expected eqv $v, "Expected value received";
});

for @to_send -> $byte {
    $supplier.emit( $byte );
}
