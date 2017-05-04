use v6;
use Test;
use Native::Packing :Endian;

class N does Native::Packing[Network] {
      has uint8  $.a;
      has uint16 $.b;
      has uint8  $!c;
      has num32  $.float;
      method TWEAK(:$!c) {}
}

is N.bytes, 8, '.bytes';
my $struct = N.new: :a(10), :b(20), :c(30), :float(42e0);

my $n-buf = $struct.pack;
is-deeply $n-buf, Buf[uint8].new(10, 0, 20, 30, 66, 40, 0, 0), 'network packing';

my $n-struct = N.unpack: $n-buf;

is-deeply $n-struct, $struct, 'network pack/unpack round-trip';

class V does Native::Packing[Vax] {
      has uint8  $.a;
      has uint16 $.b;
      has uint8  $!c;
      has num32  $.float;
      method TWEAK(:$!c) {}
}

$struct = V.new: :a(10), :b(20), :c(30), :float(42e0);

my $v-buf = $struct.pack;
is-deeply $v-buf, Buf[uint8].new(10, 20, 0, 30, 0, 0, 40, 66), 'vax pack/unpack round-trip';

my $v-struct = V.unpack: $v-buf;

is-deeply $v-struct, $struct, 'vax round-trip';

class H does Native::Packing[Host] {
      has uint8  $.a;
      has uint16 $.b;
      has uint8  $!c;
      has num32  $.float;
      method TWEAK(:$!c) {}
}

$struct = H.new: :a(10), :b(20), :c(30), :float(42e0);
my $h-buf = $struct.pack;
my $h-struct = H.unpack: $h-buf;
is-deeply $h-struct, $struct, 'host round-trip';

done-testing;
