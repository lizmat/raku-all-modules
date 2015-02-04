use v6;
use Test;
plan *;
use Math::Quaternion;

class EmptySubclass is Math::Quaternion {};

my $e = EmptySubclass.new;
my $u = EmptySubclass.unit;

isa_ok $e, Math::Quaternion, 'A new EmptySubclass isa Math::Quaternion';
isa_ok $e, EmptySubclass,    'A new EmptySubclass isa EmptySubclass';

is     $u * 2 + $e, '2 + 0i + 0j + 0k',  '.unit, math, and .Str work';

done;
# vim: ft=perl6
