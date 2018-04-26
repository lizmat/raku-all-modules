use v6.c;
use Test;
use Hash::Util;

my @supported = <
  all_keys all_ref_keys hash_locked hash_unlocked hashref_locked
  hashref_unlocked hidden_keys hidden_ref_keys legal_keys legal_ref_keys
  lock_hash lock_hash_recurse lock_hashref lock_hashref_recurse lock_keys
  lock_keys_plus lock_ref_keys lock_ref_keys_plus lock_ref_value lock_value
  unlock_hash unlock_hash_recurse unlock_hashref unlock_hashref_recurse
  unlock_keys unlock_ref_keys unlock_ref_value unlock_value
>.map: '&' ~ *;

plan @supported * 2;

for @supported {
    ok !defined(::($_))                # nothing here by that name
      || ::($_) !=== Hash::Util::{$_}, # here, but not the one from List::Util
      "is $_ NOT imported?";
    ok defined(Hash::Util::{$_}), "is $_ externally accessible?";
}

# vim: ft=perl6 expandtab sw=4
