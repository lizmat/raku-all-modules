use v6.c;
use Test;
use Hash::Util <
  lock_keys lock_keys_plus unlock_keys legal_keys hidden_keys all_keys
  hash_locked hash_unlocked
>;

plan 34;

my @unhidden = <a b>;
my @hidden = <c d>;
my @legal = |@unhidden, |@hidden;
my %hash = a => 42, b => 666;

ok lock_keys(%hash,@legal) =:= %hash, 'does lock_keys return %hash';

ok %hash<a>:exists, 'does "a" still exist';
is %hash<a>, 42, 'does "a" still have the same value';
ok %hash<b>:exists, 'does "b" still exist';
is %hash<b>, 666, 'does "b" still have the same value';
nok %hash<c>:exists, 'does "c" not exist';
nok %hash<c>.defined, 'is "c" value not defined';
nok %hash<d>:exists, 'does "d" not exist';
nok %hash<d>.defined, 'is "d" value not defined';

is legal_keys(%hash).sort,@legal, 'do we have the right legal keys';
is hidden_keys(%hash).sort,@hidden, 'do we have the right hidden keys';

ok all_keys(%hash,my @visible,my @invisible) =:= %hash,
  'does all_keys return %hash';
is @visible.sort, @unhidden, 'did we get the right visible keys';
is @invisible.sort, @hidden, 'did we get the right hidden keys';

is (%hash<c> = 89), 89, 'can we assign to "c"';
is (%hash<d> = 66), 66, 'can we assign to "d"';

is %hash<a>:delete, 42, 'can we delete "a"';
nok %hash<a>:exists, 'does "a" not exist again';
nok %hash<a>.defined, 'is "a" not defined again';
is (%hash<a> = 77), 77, 'can we assign to "a" again';

my $caught = 0;
{ %hash<e>; CATCH { default { ++$caught } } }
is $caught, 1, 'did we get an exception for access unexisting';

$caught = 0;
{ %hash<e>:delete; CATCH { default { ++$caught } } }
is $caught, 1, 'did we get an exception for attempting to delete unexisting';

ok hash_locked(%hash), 'is the hash marked as locked?';
nok hash_unlocked(%hash), 'is the hash NOT marked as unlocked?';

ok lock_keys_plus(%hash,<a e>) =:= %hash, 'does lock_keys_plus return %hash';
ok %hash<a>:exists, 'does "a" still exist';
is %hash<a>, 77, 'does "a" still have the same value';
nok %hash<e>:exists, 'does "e" not exist yet';
nok %hash<e>.defined, 'is "e" value not defined yet';

is (%hash<e> = 271), 271, 'can we assign to "e"';
ok %hash<e>:exists, 'does "e" exist now';

ok unlock_keys(%hash) =:= %hash, 'does unlock_keys return %hash';
nok hash_locked(%hash), 'is the hash NOT marked as locked?';
ok hash_unlocked(%hash), 'is the hash marked as unlocked?';

# vim: ft=perl6 expandtab sw=4
