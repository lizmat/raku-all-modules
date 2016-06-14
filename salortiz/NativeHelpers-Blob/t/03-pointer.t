use v6;
use Test;
use NativeCall;

plan 10;

use NativeHelpers::Pointer;

my CArray[uint16] $a .= new: 10, 20 ... 100;

my $p = nativecast(Pointer[uint16], $a);

is $p.deref, 10, 'expected 10';

ok (my $np = $p.succ), 'succ works';

isa-ok $np, Pointer[uint16];

is $np - $p, nativesizeof(uint16), 'expected offset';

is $np.deref, 20, 'expected 20';

ok $np++, 'postfix ++';

is $np.deref, 30, 'expected 30';

$np = $p + 3;

is $np.deref, 40, 'expected 40';

ok $p == $np.pred.pred.pred,  'pred works';

dies-ok {
    Pointer.new.succ;
}, "void pointer not allowed";
