use v6;
use lib './t';
use Test;
use NativeCall;
use NativeHelpers::Blob;
use CompileTestLib;

plan 25;

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

is $la.elems, 10,                                                          'elems';
is $la.shape, (10,),                                               'Correct shape';

is $la.nativesizeof, $size * 10,                    "Array size is { $size * 10 }";

ok my $bp = $la.bare-pointer,                               'Defined base pointer';
isa-ok $bp, Pointer,                                              'A bare pointer';
#diag $bp;

ok my $tp = $la.typed-pointer,                              'Defined type pointer';
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

# Now a real NC tests
is myaddr($la.typed-pointer).Int, $bp.Int,                              'Indeed';
is shown($la.typed-pointer, 3), 'x:3, y:30, z:300',                     'Works!';

ok $la.dispose,                                                    'Can dispose';
is $la.elems, 0,                                                  'Now is empty';
