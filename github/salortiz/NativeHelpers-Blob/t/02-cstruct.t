use v6;
use lib './t';
use Test;
use NativeCall;
use NativeHelpers::Pointer;
use NativeHelpers::Blob;
use CompileTestLib;

plan 35;

compile_test_lib('02-cstruct');

use-ok 'NativeHelpers::CStruct';

use NativeHelpers::CStruct;

# Class for tests;
class Point3D is repr('CStruct') {
    has int64 $.x is rw;
    has int64 $.y is rw;
    has int64 $.z is rw;
}

sub myaddr(Point3D --> Str)       is native('./02-cstruct') { * }
sub shown(Point3D, int32 --> Str) is native('./02-cstruct') { * }

# Test basic properties
my $size = 3 * nativesizeof(int64);
is nativesizeof(Point3D), $size,                            "Correct size ($size)";

ok LinearArray[Point3D] ~~ Any,                                          'A class';

ok my $la = LinearArray[Point3D].new(10),                        'Can instantiate';

ok $la.managed,                                                          'managed';
is $la.elems, 10,                                                          'elems';
is $la.shape, (10,),                                               'Correct shape';

is $la.nativesizeof, $size * 10,                    "Array size is { $size * 10 }";

ok my $bp = $la.Pointer,                                    'Defined base pointer';
isa-ok $bp, Pointer,                                              'A bare pointer';
#diag $bp;

ok my $tp = $la.base,                                        'Defined base object';
isa-ok $tp, Point3D,                        'A typed object, passed by ref to NCs';
#diag $tp;

ok my $rp = $la._Pointer(0),                                'Defined st pointer 0';
isa-ok $rp, Pointer,                             'Can get a pointer to first elem';
#diag $rp;

is +$bp, +$rp,                                                'Base address match';
#diag (+$la._Pointer(3)).base(16);

# Test element access
isa-ok $la[0], Point3D,                                      "At 0 is-a 'Point3D'";
ok $la[0].defined,                                                       'Defined';

isa-ok $la[2], Point3D,                                      "At 2 is-a 'Point3D'";
ok $la[2].defined,                                                       'Defined';

dies-ok {
    $la[10], Point3D
},                                                              'Outside of range';

lives-ok {
    for ^10 -> $i {
        with $la[$i] {
            .x = $i * 1;
            .y = $i * 10;
            .z = $i * 100;
        }
    }
},                                                       'Can set objs attributes';

# For check setted values, convert to Blob[int64]
my $blob = blob-from-pointer($bp,
    :elems(($la.nativesizeof / nativesizeof(int64)).Int),
    :type(Blob[int64])
);

my $ok = True;
for ^10 -> $base {
    for ^3 -> $ele {
        $ok &&= $blob[$base*3 + $ele] == $base * 10 ** $ele;
    }
}
ok $ok,                                                 'Elements in blob match';
#diag $blob.perl;

# Test via pointer arithmetic
$tp = $la.Pointer(:typed);
isa-ok $tp, Pointer[Point3D];
for ^10 -> $el {
    with $tp.deref {
        $ok &&= .x == $el;
        $ok &&= .y == $el * 10;
        $ok &&= .z == $el * 100;
    }
    $tp++;
}
ok $ok,                                                       'Expected values';

# Tests for unmanaged
my LinearArray[Point3D] $lum .= new-from-pointer(:ptr($la.Pointer), :10size);
ok $lum ~~ LinearArray[Point3D],                                      'created';
is $lum.elems,  10,                                                      'size';
nok $lum.managed,                                                   'unmanaged';

# Now a real NC tests
is myaddr($la.base).Int, $bp.Int,                                       'Indeed';
is shown($la.base, 3), 'x:3, y:30, z:300',                              'Works!';

is shown($lum.base, 3), 'x:3, y:30, z:300',                      'The same data';
is +pointer-to($lum[3]), +$la._Pointer(3),                    'At the same addr';

isnt $lum[3], $la[3],                                      'but no the same obj';

ok $lum.dispose,                                             'Dispose unmanaged';
ok $la.dispose,                                                    'Can dispose';
is $la.elems, 0,                                                  'Now is empty';
