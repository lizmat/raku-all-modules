use v6;
use Test;
use Data::MessagePack::StreamingUnpacker;

plan 3;

my @to_send = 0xc4, 3, 1, 2, 3,
 0xc5, 0x01, 0x00, |(13 xx (2**8) ),
 0xc6, 0x00, 0x01, 0x00, 0x00, |(14 xx (2**16) )
;

my @expected = Blob.new(1, 2, 3),
 Blob.new(13 xx 2**8),
 Blob.new(14 xx 2**16)
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
