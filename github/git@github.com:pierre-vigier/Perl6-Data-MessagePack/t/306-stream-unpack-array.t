use v6;
use Test;
use Data::MessagePack::StreamingUnpacker;

plan 3;

my @to_send = 0x90,
 0xdc, 0x00, 0x10, |(|(0xcc, 0xfa) xx 16 ),
  148,160,161,97,162,98,99,163,100,101,102
 ;

my @expected = [],
 [ 250 xx 16 ],
 ["", "a", "bc", "def"],
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
