use v6;
use Test;
use Native::Packing :Endian;
plan 2;

class C does Native::Packing[Host] { has int16 $.a }
my $c = C.new: :a(42);
my $packed = $c.pack;

given Native::Packing.host-endian {
    when Vax {
	pass "host endian detection (got:Vax)";
	is-deeply $packed, buf8.new(0x2a, 0), 'packing endian';
    }
    when Network {
	pass "host endian detection (got:Network)";
	is-deeply $packed, buf8.new(0, 0x2a), 'packing endian';
    }
    default {
	flunk "host endian detection (got:{.perl})";
	skip 'packing endian';
    }
}

done-testing;
