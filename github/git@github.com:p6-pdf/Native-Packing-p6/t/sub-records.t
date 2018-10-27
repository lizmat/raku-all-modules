use v6;
use Test;
use Native::Packing :Endian;

class SubStruct1 does Native::Packing[Network] {
        has uint16 $.a;
        has uint8  $.b;
}

class SubStruct2 does Native::Packing[Vax] {
        has uint32 $.c;
}

class NetStruct does Native::Packing[Network] {
    has SubStruct1 $.s1;
    has uint16 $.v;
    has SubStruct2 $.s2;
}

my $s1 = SubStruct1.new(:a(42), :b(99));
my $s2 = SubStruct2.new(:c(42));

my $n = NetStruct.new: :$s1, :v(42), :$s2;

my $n-buf = $n.pack;
is-deeply $n-buf.list, (
    0,42, 99,
    0,42,
    42,0,0,0), 'network struct packing';

my $n2 = NetStruct.unpack($n-buf);
is-deeply $n2, $n, 'network struct unpacking';

is-deeply NetStruct.new.pack.list, (0 xx 9), 'network packing empty';

class VaxStruct does Native::Packing[Vax] {
    has SubStruct1 $.s1;
    has uint16 $.v;
    has SubStruct2 $.s2;
}

my $v = VaxStruct.new: :$s1, :v(42), :$s2;

my $v-buf = $v.pack;
is-deeply $v-buf.list, (
    0,42, 99,
    42,0,
    42,0,0,0), 'vax struct packing';

my $v2 = VaxStruct.unpack($v-buf);
is-deeply $v2, $v, 'vax struct unpacking';

is-deeply VaxStruct.new.pack.list, (0 xx 9), 'vax packing empty';

done-testing;
