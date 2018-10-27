use v6;
use Test;
use NativeCall;

plan 24;

use-ok 'NativeHelpers::Blob';

use NativeHelpers::Blob;
#$NativeHelpers::Blob::debug = True;

my $a = 'Hola a todos'.encode;
my @orig = $a.list;
isa-ok $a, utf8; # Sanity check
my $orig-type = $a.^array_type;

is sizeof($a), 12,			'sizeof Blob';

ok (my $au = carray-from-blob($a)),	'carray from blob';
isa-ok $au, CArray;
dies-ok { $au.elems },			'Can´t get size';
ok not carray-is-managed($au),		'Not managed';

is +pointer-to($a), +pointer-to($au),	'shares memory';

ok my $am = carray-from-blob($a):managed, 'c-f-b managed';
isa-ok $am, CArray;
ok so carray-is-managed($am),		'Is managed';
ok $am.elems == 12,			'Correct size';
is sizeof($am), 12,			'sizeof CArray';

isa-ok pointer-to($am, :typed).of, $orig-type;

ok $am.list eqv @orig.flat.list,	'Elems match';

my $bu = blob-from-carray($am);
is $bu.decode, 'Hola a todos',		'Full trip';


ok (my $b2 = blob-from-carray($au):12size), 'With size';
is $b2.decode, 'Hola a todos',		'The same';

ok my $ps = ptr-sized($am),		'A ptr-sized';
isa-ok $ps, Capture;
is $ps.elems, 2,			'has two elems';
isa-ok $ps[0], Pointer,			'first isa Pointer';
isa-ok $ps[1], Int,			'Second isa Int';

is utf8-from-pointer(|$ps), $a,		'utf8-f-p works';
