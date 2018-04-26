[![Build Status](https://travis-ci.org/lizmat/Hash-Util.svg?branch=master)](https://travis-ci.org/lizmat/Hash-Util)

NAME
====

Hash::Util - Port of Perl 5's Hash::Util 0.22

SYNOPSIS
========

    use Hash::Util <
      lock_hash unlock_hash lock_hash_recurse unlock_hash_recurse
      lock_keys lock_keys_plus unlock_keys
      lock_value unlock_value
      hash_locked hash_unlocked
      hidden_keys legal_keys all_keys
    >;

    my %hash = foo => 42, bar => 23;

    # Ways to restrict a hash
    lock_keys(%hash);
    lock_keys(%hash, @keyset);
    lock_keys_plus(%hash, @additional_keys);

    # Ways to inspect the properties of a restricted hash
    my @legal = legal_keys(%hash);
    my @hidden = hidden_keys(%hash);
    all_keys(%hash,@keys,@hidden);
    my $is_locked = hash_locked(%hash);

    # Remove restrictions on the hash
    unlock_keys(%hash);

    # Lock individual values in a hash
    lock_value(  %hash, 'foo');
    unlock_value(%hash, 'foo');

    # Ways to change the restrictions on both keys and values
    lock_hash  (%hash);
    unlock_hash(%hash);

DESCRIPTION
===========

Hash::Util contains a set of functions that support restricted hashes. It introduces the ability to restrict a hash to a certain set of keys. No keys outside of this set can be added. It also introduces the ability to lock an individual key so it cannot be deleted and the ability to ensure that an individual value cannot be changed.

By default Hash::Util does not export anything.

MAYBE MAP IS ALL YOU NEED
=========================

If you want to use this module for the sole purpose of only once locking a hash into an immutable state (calling only `lock_hash` once on a hash), then it is much better to turn your hash into a `Map` upon initialization by adding the `is Map` trait:

    my %hash is Map = foo => 42, bar => 23;

This will have exactly the same effect as:

    my %hash = foo => 42, bar => 23;
    lock_hash(%hash);

but won't need to load the `Hash::Util` module and will be much better performant because it won't need any additional run-time checks, because `Map` is the immutable version of `Hash` in Perl 6.

PORTING CAVEATS
===============

Functions that pertain to the unique implementation of Perl 5 hashes, have **not** been ported. These include:

    hash_seed hash_value hv_store bucket_stats
    bucket_info bucket_array hash_traversal_mask

Also field hashes (the tools to create inside-out objects) have not been ported is these were deemed rather useless in the Perl 6 environment where everything is a true object. This pertains to the functions:

    fieldhash fieldhashes

Since the concept of references does not exist as such in Perl 6, it didn't make sense to separately port the "_ref" versions of the subroutines. They are however available as aliases to the non "_ref" versions::

    lock_hashref unlock_hashref lock_hashref_recurse unlock_hashref_recurse
    lock_ref_keys lock_ref_keys_plus unlock_ref_keys
    lock_ref_value unlock_ref_value
    hashref_locked hashref_unlocked

FUNCTIONS
=========

lock_keys HASH, [KEYS]
----------------------

    lock_keys(%hash);
    lock_keys(%hash, @keys);

Restricts the given %hash's set of keys to @keys. If @keys is not given it restricts it to its current keyset. No more keys can be added. `:delete` and `:exists` will still work, but will not alter the set of allowed keys. Returns the hash it worked on.

unlock_keys HASH
----------------

    unlock_keys(%hash);

Removes the restriction on the %hash's keyset.

**Note** that if any of the values of the hash have been locked they will not be unlocked after this sub executes. Returns the hash it worked on.

lock_keys_plus HASH, KEYS
-------------------------

    lock_keys_plus(%hash,@additional_keys)

Similar to `lock_keys`, with the difference being that the optional key list specifies keys that may or may not be already in the hash. Essentially this is an easier way to say

    lock_keys(%hash,@additional_keys,%hash.keys);

lock_value HASH, KEY
--------------------

    lock_value(%hash, $key);

Locks the value for an individual key of a hash. The value of a locked key cannot be changed. Unless %hash has already been locked the key/value could be deleted regardless of this setting. Returns the hash on which it operated.

unlock_value HASH, KEY
----------------------

    unlock_value(%hash, $key);

Unlocks the value for an individual key of a hash. Returns the hash on which it operated.

lock_hash HASH
--------------

    lock_hash(%hash);

Locks an entire hash, making all keys and values read-only. No value can be changed, no keys can be added or deleted. Returns the hash it operated on. If you only want to lock a hash only once after it has been initialized, it's better to make it a `Map`:

    my %hash is Map = foo => 42, bar => 23;

This will have the same effect as `lock_hash`, but will be much more performant as no extra overhead is needed for checking access at runtime.

unlock_hash HASH
----------------

    unlock_hash(%hash);

Does the opposite of `lock_hash`. All keys and values are made writable. All values can be changed and keys can be added and deleted. Returns the hash it operated on.

lock_hash_recurse HASH
----------------------

    lock_hash_recurse(%hash);

Locks an entire hash and any hashes it references recursively, making all keys and values read-only. No value can be changed, no keys can be added or deleted. Returns the hash it originally operated on.

This method **only** recurses into hashes that are referenced by another hash. Thus a Hash of Hashes (HoH) will all be restricted, but a Hash of Arrays of Hashes (HoAoH) will only have the top hash restricted.

unlock_hash_recurse HASH
------------------------

    unlock_hash_recurse(%hash);

Does the opposite of lock_hash_recurse(). All keys and values are made writable. All values can be changed and keys can be added and deleted. Returns the hash it originally operated on.

Identical recursion restrictions apply as to `lock_hash_recurse`.

hash_locked HASH
----------------

    say "Hash is locked!" if hash_locked(%hash);

Returns true if the hash and/or its keys are locked.

hash_unlocked HASH
------------------

    say "Hash is unlocked!" if hash_unlocked(%hash);

Returns true if the hash and/or its keys are **not** locked.

legal_keys HASH
---------------

    my @legal = legal_keys(%hash);

Returns the list of the keys that are legal in a restricted hash. In the case of an unrestricted hash this is identical to calling `%hash.keys`.

hidden_keys HASH
----------------

    my @hidden = hidden_keys(%hash);

Returns the list of the keys that are legal in a restricted hash but do not have a value associated to them. Thus if 'foo' is a "hidden" key of the %hash it will return False for both `defined` and `:exists` tests.

In the case of an unrestricted hash this will return an empty list.

all_keys HASH, VISIBLE, HIDDEN
------------------------------

    all_keys(%hash,@visible,@hidden);

Populates the arrays @visible with the all the keys that would pass an `exists` tests, and populates @hidden with the remaining legal keys that have not been utilized. Returns the hash it operated on.

SEE ALSO
========

[Scalar::Util](Scalar::Util), [List::Util](List::Util)

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/Hash-Util . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

Re-imagined from the Perl 5 version as part of the CPAN Butterfly Plan. Perl 5 version originally developed by the Perl 5 Porters, subsequently maintained by Steve Hay.

