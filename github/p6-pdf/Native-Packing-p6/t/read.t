use v6;
use Test;
use Native::Packing :Endian;

class NetStruct does Native::Packing[Network] {
    has uint16 $.v;
}

class VaxStruct does Native::Packing[Vax] {
    has uint16 $.v;
}

class N does Native::Packing[Network] {
      has uint8  $.a;
      has uint16 $.b;
      has uint8  $.c;
      has num32  $.float;
      has NetStruct $.net;
      has VaxStruct $.vax;
  }

my $net = NetStruct.new: :v(42);
my $vax = VaxStruct.new: :v(99);

my $struct = N.new: :a(10), :b(20), :c(30), :float(42e0), :$net, :$vax;
my $out-fh = "t/net.bin".IO.open(:bin, :w);
$struct.write: $out-fh;
$out-fh.close;
my $n-buf = "t/net.bin".IO.open(:bin, :r).read;
is-deeply $n-buf, Buf[uint8].new(10, 0,20, 30, 66,40,0,0, 0,42, 99,0), 'network write';

my $n-struct = N.read: "t/net.bin".IO.open(:bin, :r);
is-deeply $n-struct, $struct, 'network write/read round-trip';

class V does Native::Packing[Vax] {
      has uint8  $.a;
      has uint16 $.b;
      has uint8  $.c;
      has num32  $.float;
      has NetStruct $.net;
      has VaxStruct $.vax;
}

$struct = V.new: :a(10), :b(20), :c(30), :float(42e0), :$net, :$vax;
$out-fh = "t/vax.bin".IO.open(:bin, :w);
$struct.write: $out-fh;
$out-fh.close;
my $v-buf = "t/vax.bin".IO.open(:bin, :r).read;
is-deeply $v-buf, Buf[uint8].new(10, 20,0, 30,0,0,40,66, 0,42, 99,0), 'vax write';

my $v-struct = V.read: "t/vax.bin".IO.open(:bin, :r);
is-deeply $v-struct, $struct, 'vax write/read round-trip';

done-testing;


