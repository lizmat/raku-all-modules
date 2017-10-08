use v6;
use Test;
use Data::MessagePack::StreamingUnpacker;

plan 2;

my @to_send = 0xc0,0xc0;

my @expected = Any, Any;

my $supplier = Supplier.new;

my $supply = $supplier.Supply;

my $s = Data::MessagePack::StreamingUnpacker.new( source => $supplier.Supply );
my $unpacked = $s.Supply();
$unpacked.tap( -> $v {
    my $expected = @expected.shift;
    ok $expected eqv $v, "Expected value received";
} );

for @to_send -> $byte {
    $supplier.emit( $byte );
}
