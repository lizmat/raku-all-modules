use v6;
use Test;
use Data::MessagePack::StreamingUnpacker;

plan 4;

my @to_send = 0xca, 0x42, 0x02, 0x80, 0x00,
 0xca, 0x3F, 0x8C, 0xCC, 0xCD,
 ;

my @expected = 32.625, 1.1; # -147.625;

my $supplier = Supplier.new;

my $s = Data::MessagePack::StreamingUnpacker.new( source => $supplier.Supply );
my $unpacked = $s.Supply();

my $tap = $unpacked.tap( -> $v {
    my $expected = @expected.shift;
    my $*TOLERANCE = .000001;
    ok $expected =~= $v, "Expected value received, float";
});

for @to_send -> $byte {
    $supplier.emit( $byte );
}
$tap.close();

my @to_send_double = 0xcb, 192,98,116,0,0,0,0,0,
    0xcb, 0x3f, 0xf1, 0x99, 0x99, 0x99, 0x99, 0x99, 0x9a;
my @expected_double = -147.625, 1.1;

$tap = $unpacked.tap( -> $v {
    my $expected = @expected_double.shift;
    my $*TOLERANCE = 10**-15;
    ok $expected =~= $v, "Expected value received, double";
});

for @to_send_double -> $byte {
    $supplier.emit( $byte );
}
