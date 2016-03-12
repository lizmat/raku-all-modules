use v6;
use Test;
use NativeCall;

plan 14;

use-ok 'NativeHelpers::Blob';

use NativeHelpers::Blob; # Need again :-)

my $a = 'Hola a todos'.encode;
my @orig = $a.list;

isa-ok $a, utf8; # Sanity check

ok (my $au = carray-from-blob($a)),	'carray from blob';
isa-ok $au, CArray;
dies-ok { $au.elems },			'Can´t get size';
ok not carray-is-managed($au),		'Not managed';

ok my $am = carray-from-blob($a):managed, 'c-f-b managed';
isa-ok $am, CArray;
ok so carray-is-managed($am),		'Is managed';
ok $am.elems == 12,			'Correct size';

ok $am.list eqv @orig.flat.list,	'Elems match';

my $bu = blob-from-carray($am);
is $bu.decode, 'Hola a todos',		'Full trip';


ok (my $b2 = blob-from-carray($au):12size), 'With size';
is $b2.decode, 'Hola a todos',		'The same';

