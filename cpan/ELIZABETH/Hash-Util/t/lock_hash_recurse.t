use v6.c;
use Test;
use Hash::Util <
  lock_hash_recurse unlock_hash_recurse
  hash_locked hash_unlocked
>;

plan 22;

my %hash = a => 42, b => { d => 89 }, c => [ { e => 271 } ];

ok lock_hash_recurse(%hash) =:= %hash, 'does lock_hash_recurse return %hash';

ok %hash<a>:exists, 'does "a" still exist';
is %hash<a>, 42, 'does "a" still have the same value';
ok %hash<b>:exists, 'does "b" still exist';
ok %hash<c>:exists, 'does "c" still exist';

ok hash_locked(%hash), 'is the top hash marked as locked?';
nok hash_unlocked(%hash), 'is the top hash NOT marked as unlocked?';
ok hash_locked(%hash<b>), 'is the lower hash marked as locked?';
nok hash_unlocked(%hash<b>), 'is the lower hash NOT marked as unlocked?';
nok hash_locked(%hash<c>[0]), 'is the lowest hash NOT marked as locked?';
ok hash_unlocked(%hash<c>[0]), 'is the lowest hash marked as unlocked?';

ok unlock_hash_recurse(%hash) =:= %hash, 'unlock_hash_recurse return %hash';

ok %hash<a>:exists, 'does "a" still exist';
is %hash<a>, 42, 'does "a" still have the same value';
ok %hash<b>:exists, 'does "b" still exist';
ok %hash<c>:exists, 'does "c" still exist';

nok hash_locked(%hash), 'is the top hash NOT marked as locked?';
ok hash_unlocked(%hash), 'is the top hash marked as unlocked?';
nok hash_locked(%hash<b>), 'is the lower hash NOT marked as locked?';
ok hash_unlocked(%hash<b>), 'is the lower hash marked as unlocked?';
nok hash_locked(%hash<c>[0]), 'is the lowest hash still NOT marked as locked?';
ok hash_unlocked(%hash<c>[0]), 'is the lowest hash still marked as unlocked?';

# vim: ft=perl6 expandtab sw=4
