use v6.c;
use Test;
use Hash::Util <lock_hash unlock_hash hash_locked hash_unlocked>;

plan 19;

my %hash = a => 42, b => 666;

ok lock_hash(%hash) =:= %hash, 'does lock_hash return %hash';

ok %hash<a>:exists, 'does "a" still exist';
is %hash<a>, 42, 'does "a" still have the same value';
ok %hash<b>:exists, 'does "b" still exist';
is %hash<b>, 666, 'does "b" still have the same value';

my $caught = 0;
{ %hash<e>; CATCH { default { ++$caught } } }
is $caught, 1, 'did we get an exception for access unexisting';

$caught = 0;
{ %hash<e> = 77; CATCH { default { ++$caught } } }
is $caught, 1, 'did we get an exception for attempting to assign unexisting';

$caught = 0;
{ %hash<e>:delete; CATCH { default { ++$caught } } }
is $caught, 1, 'did we get an exception for attempting to delete unexisting';
ok hash_locked(%hash), 'is the hash marked as locked?';
nok hash_unlocked(%hash), 'is the hash NOT marked as unlocked?';

ok unlock_hash(%hash) =:= %hash, 'does unlock_hash return %hash';
nok hash_locked(%hash), 'is the hash NOT marked as locked?';
ok hash_unlocked(%hash), 'is the hash marked as unlocked?';

is (%hash<c> = 89), 89, 'can we assign to "c"';
is (%hash<d> = 66), 66, 'can we assign to "d"';

is %hash<a>:delete, 42, 'can we delete "a"';
nok %hash<a>:exists, 'does "a" not exist again';
nok %hash<a>.defined, 'is "a" not defined again';
is (%hash<a> = 77), 77, 'can we assign to "a" again';

# vim: ft=perl6 expandtab sw=4
