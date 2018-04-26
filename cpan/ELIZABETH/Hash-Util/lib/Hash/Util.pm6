use v6.c;

#---- role to mix into Associative class ---------------------------------------
role LockedHash {
    has int $!lock_hash;
    has int $!lock_keys;

    #---- original Associative candidates --------------------------------------
    has $!EXISTS-KEY;
    has $!AT-KEY;
    has $!ASSIGN-KEY;
    has $!BIND-KEY;
    has $!DELETE-KEY;

    #---- shortcuts to exceptions ----------------------------------------------
    sub disallowed($key --> Nil) is hidden-from-backtrace {
       die "Attempt to access disallowed key '$key' in a restricted hash"
    }
    sub readonly($key --> Nil) is hidden-from-backtrace {
       die "Modification of a read-only value attempted"
    }
    sub missed(@missed --> Nil) is hidden-from-backtrace {
       die @missed == 1
         ?? "Hash has key '@missed[0]' which is not in the new key set"
         !! "Hash has keys '@missed.join(q/','/)' which are not in the new key set"
    }
    sub delete($key,$type --> Nil) is hidden-from-backtrace {
       die "Attempt to delete $type key '$key' from a restricted hash"
    }

    #---- initialization -------------------------------------------------------
    my constant HIDDEN = Mu.new
      but role { method defined { False } };     # sentinel for hidden keys

    submethod initialize(
      $!EXISTS-KEY,$!AT-KEY,$!ASSIGN-KEY,$!BIND-KEY,$!DELETE-KEY
    ) {
        self
    }

    #---- helper methods -------------------------------------------------------
    method !delete_key(\key) {
        my $value = $!AT-KEY(self,key);
        $!ASSIGN-KEY(self,key,HIDDEN);
        $value
    }

    #---- standard Associative interface ---------------------------------------
    method EXISTS-KEY(\key) {
        use nqp;  # we need nqp::decont here for some reason
        $!EXISTS-KEY(self,key) && !(nqp::decont($!AT-KEY(self,key)) =:= HIDDEN)
    }
    method AT-KEY(\key) is raw {
        $!EXISTS-KEY(self,key)
          ?? $!lock_hash                   # key exists
            ?? $!AT-KEY(self,key)<>          # and locked hash, so decont
            !! $!AT-KEY(self,key)            # and NO locked hash, so pass on
          !! $!lock_hash || $!lock_keys    # key does NOT exist
            ?? disallowed(key)               # and locked hash/keys, forget it
            !! $!AT-KEY(self,key)            # and NO lock, so pass on
    }

    method ASSIGN-KEY(\key, \value) is raw {
        $!EXISTS-KEY(self,key)
          ?? $!lock_hash                   # key exists
            ?? readonly(key)                 # and locked hash, so forget it
            !! $!ASSIGN-KEY(self,key,value)  # and NO locked hash, so pass on
          !! $!lock_hash || $!lock_keys    # key does NOT exist
            ?? disallowed(key)               # and locked hash/keys, forget it
            !! $!ASSIGN-KEY(self,key,value)  # and NO lock, so pass on
    }

    method BIND-KEY(\key, \value) is raw {
        $!EXISTS-KEY(self,key)
          ?? $!lock_hash                   # key exists
            ?? readonly(key)                 # and locked hash, so forget it
            !! $!BIND-KEY(self,key,value)    # and NO locked hash, so pass on
          !! $!lock_hash || $!lock_keys    # key does NOT exist
            ?? disallowed(key)               # and locked hash/keys, forget it
            !! $!BIND-KEY(self,key,value)    # and NO lock, so pass on
    }

    method DELETE-KEY(\key) is raw {
        $!EXISTS-KEY(self,key)
          ?? $!lock_hash                   # key exists
            ?? delete(key,'readonly')        # and locked hash, forget it
            !! $!lock_keys                   # and NO locked hash
              ?? self!delete_key(key)          # but locked keys, so fake it
              !! $!DELETE-KEY(self,key)        # no locked keys, so do it
          !! $!lock_hash || $!lock_keys    # key does NOT exist
            ?? delete(key,'disallowed')      # and locked hash/keys, forget it
            !! Nil                           # not locked, so just show absence
    }

    #---- behaviour modifiers --------------------------------------------------
    method lock_hash()   { $!lock_hash = 1; self }
    method unlock_hash() { $!lock_hash = 0; self }

    method lock_keys(@keys,:$plus)   {
        if @keys {
            $!ASSIGN-KEY(self,$_,HIDDEN) unless $!EXISTS-KEY(self,$_) for @keys;

            unless $plus {
                missed( (self (-) @keys).keys ) if self.elems > @keys;
            }
        }

        $!lock_keys = 1;
        self
    }
    method unlock_keys() { $!lock_keys = 0; self }

    method lock_value(\key) {
        $!BIND-KEY(self,key,$!AT-KEY(self,key)<>);
        self
    }
    method unlock_value(\key) {
        my \value := $!AT-KEY(self,key);
        $!DELETE-KEY(self,key);
        $!ASSIGN-KEY(self,key,value);
        self
    }

    #---- introspection --------------------------------------------------------
    method hash_locked()   {  so $!lock_hash || $!lock_keys }
    method hash_unlocked() { not $!lock_hash || $!lock_keys }

    method legal_keys() {
        self.keys.List
    }
    method hidden_keys() {
        use nqp;  # we need nqp::decont here for some reason
        self.pairs.map({ .key if nqp::decont(.value) =:= HIDDEN }).List
    }
    method all_keys(\existing,\hidden) {
        use nqp;  # we need nqp::decont here for some reason
        nqp::decont(.value) =:= HIDDEN
          ?? hidden.push(.key)
          !! existing.push(.key)
          for self.pairs;
        self
    }
}

#---- actual module with exportable subs ---------------------------------------
module Hash::Util:ver<0.0.1>:auth<cpan:ELIZABETH> {

    #---- helper subs ----------------------------------------------------------
    my List %candidates;
    my $lock = Lock.new;

    sub candidates(\the-hash) {
        $lock.protect: {
            %candidates{the-hash.^name} //= (
              the-hash.can('EXISTS-KEY').head,
              the-hash.can(    'AT-KEY').head,
              the-hash.can('ASSIGN-KEY').head,
              the-hash.can(  'BIND-KEY').head,
              the-hash.can('DELETE-KEY').head,
            )
        }
    }

    #---- lock_hash / unlock_hash ----------------------------------------------
    our proto sub lock_hash(|) is export(:all) {*}
    multi sub lock_hash(Associative:D \the-hash) {
        my @candidates := candidates(the-hash);
        (the-hash does LockedHash).initialize(|@candidates).lock_hash
    }
    multi sub lock_hash(LockedHash:D \the-hash) is default {
        the-hash.lock_hash
    }
    our constant &lock_hashref is export(:all) = &lock_hash;

    our proto sub unlock_hash(|) is export(:all) {*}
    multi sub unlock_hash(Associative:D \the-hash) {
        my @candidates := candidates(the-hash);
        (the-hash does LockedHash).initialize(|@candidates).unlock_hash
    }
    multi sub unlock_hash(LockedHash:D \the-hash) is default {
        the-hash.unlock_hash
    }
    our constant &unlock_hashref is export(:all) = &unlock_hash;

    #---- lock_hash_recurse / unlock_hash_recurse ------------------------------
    our proto sub lock_hash_recurse(|) is export(:all) {*}
    multi sub lock_hash_recurse(Associative:D \the-hash) {
        my @candidates := candidates(the-hash);
        lock_hash_recurse((the-hash does LockedHash).initialize(|@candidates))
    }
    multi sub lock_hash_recurse(LockedHash:D \the-hash) is default {
        lock_hash_recurse($_) if $_ ~~ Associative for the-hash.values;
        the-hash.lock_hash
    }
    our constant &lock_hashref_recurse is export(:all) = &lock_hash_recurse;

    our proto sub unlock_hash_recurse(|) is export(:all) {*}
    multi sub unlock_hash_recurse(Associative:D \the-hash) {
        my @candidates := candidates(the-hash);
        unlock_hash_recurse((the-hash does LockedHash).initialize(|@candidates))
    }
    multi sub unlock_hash_recurse(LockedHash:D \the-hash) is default {
        unlock_hash_recurse($_) if $_ ~~ LockedHash for the-hash.values;
        the-hash.unlock_hash
    }
    our constant &unlock_hashref_recurse is export(:all) = &unlock_hash_recurse;

    #---- lock_keys / lock_keys_plus / unlock_keys -----------------------------
    our proto sub lock_keys(|) is export(:all) {*}
    multi sub lock_keys(Associative:D \the-hash, *@keys) {
        my @candidates := candidates(the-hash);
        (the-hash does LockedHash).initialize(|@candidates).lock_keys(@keys)
    }
    multi sub lock_keys(LockedHash:D \the-hash, *@keys) is default {
        the-hash.lock_keys(@keys)
    }
    our constant &lock_ref_keys is export(:all) = &lock_keys;

    our proto sub lock_keys_plus(|) is export(:all) {*}
    multi sub lock_keys_plus(Associative:D \the-hash, *@keys) {
        my @candidates := candidates(the-hash);
        (the-hash does LockedHash)
          .initialize(|@candidates).lock_keys(@keys,:plus)
    }
    multi sub lock_keys_plus(LockedHash:D \the-hash, *@keys) is default {
        the-hash.lock_keys(@keys,:plus)
    }
    our constant &lock_ref_keys_plus is export(:all) = &lock_keys_plus;

    our proto sub unlock_keys(|) is export(:all) {*}
    multi sub unlock_keys(Associative:D \the-hash) {
        my @candidates := candidates(the-hash);
        (the-hash does LockedHash).initialize(|@candidates).unlock_keys
    }
    multi sub unlock_keys(LockedHash:D \the-hash) is default {
        the-hash.unlock_keys
    }
    our constant &unlock_ref_keys is export(:all) = &unlock_keys;

    #---- lock_value / unlock_value --------------------------------------------
    our proto sub lock_value(|) is export(:all) {*}
    multi sub lock_value(Associative:D \the-hash, \key) {
        my @candidates := candidates(the-hash);
        (the-hash does LockedHash).initialize(|@candidates).lock_value(key)
    }
    multi sub lock_value(LockedHash:D \the-hash, \key) is default {
        the-hash.lock_value(key)
    }
    our constant &lock_ref_value is export(:all) = &lock_value;

    our proto sub unlock_value(|) is export(:all) {*}
    multi sub unlock_value(Associative:D \the-hash, \key) {
        my @candidates := candidates(the-hash);
        (the-hash does LockedHash).initialize(|@candidates),unlock_value(key)
    }
    multi sub unlock_value(LockedHash:D \the-hash, \key) is default {
        the-hash.unlock_value(key)
    }
    our constant &unlock_ref_value is export(:all) = &unlock_value;

    #---- hash_locked / hash_unlocked ------------------------------------------
    our proto sub hash_locked(|) is export(:all) {*}
    multi sub hash_locked(Associative:D \the-hash) {
        my @candidates := candidates(the-hash);
        (the-hash does LockedHash).initialize(|@candidates).hash_locked
    }
    multi sub hash_locked(LockedHash:D \the-hash) is default {
        the-hash.hash_locked
    }
    our constant &hashref_locked is export(:all) = &hash_locked;

    our proto sub hash_unlocked(|) is export(:all) {*}
    multi sub hash_unlocked(Associative:D \the-hash) {
        my @candidates := candidates(the-hash);
        (the-hash does LockedHash).initialize(|@candidates).hash_unlocked
    }
    multi sub hash_unlocked(LockedHash:D \the-hash) is default {
        the-hash.hash_unlocked
    }
    our constant &hashref_unlocked is export(:all) = &hash_unlocked;

    #---- introspection --------------------------------------------------------
    our proto sub legal_keys(|) is export(:all) {*}
    multi sub legal_keys(Associative:D \the-hash) {
        the-hash.keys.List
    }
    multi sub legal_keys(LockedHash:D \the-hash) is default {
        the-hash.legal_keys
    }
    our constant &legal_ref_keys is export(:all) = &legal_keys;

    our proto sub hidden_keys(|) is export(:all) {*}
    multi sub hidden_keys(Associative:D \the-hash) {
        ()
    }
    multi sub hidden_keys(LockedHash:D \the-hash) is default {
        the-hash.hidden_keys
    }
    our constant &hidden_ref_keys is export(:all) = &hidden_keys;

    our proto sub all_keys(|) is export(:all) {*}
    multi sub all_keys(Associative:D \the-hash,\existing,\hidden) {
        existing = the-hash.keys;
        hidden = ();
        the-hash
    }
    multi sub all_keys(LockedHash:D \the-hash,\existing,\hidden) is default {
        the-hash.all_keys(existing,hidden)
    }
    our constant &all_ref_keys is export(:all) = &all_keys;
}

sub EXPORT(*@args, *%_) {

    if @args {
        my $imports := Map.new( |(EXPORT::all::{ @args.map: '&' ~ * }:p) );
        if $imports != @args {
            die "Hash::Util doesn't know how to export: "
              ~ @args.grep( { !$imports{$_} } ).join(', ')
        }
        $imports
    }
    else {
        Map.new
    }
}

=begin pod

=head1 NAME

Hash::Util - Port of Perl 5's Hash::Util 0.22

=head1 SYNOPSIS

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

=head1 DESCRIPTION

Hash::Util contains a set of functions that support restricted hashes.
It introduces the ability to restrict a hash to a certain set of keys.
No keys outside of this set can be added. It also introduces the ability
to lock an individual key so it cannot be deleted and the ability to ensure
that an individual value cannot be changed.

By default Hash::Util does not export anything.

=head1 MAYBE MAP IS ALL YOU NEED

If you want to use this module for the sole purpose of only once locking
a hash into an immutable state (calling only C<lock_hash> once on a hash),
then it is much better to turn your hash into a C<Map> upon initialization
by adding the C<is Map> trait:

    my %hash is Map = foo => 42, bar => 23;

This will have exactly the same effect as:

    my %hash = foo => 42, bar => 23;
    lock_hash(%hash);

but won't need to load the C<Hash::Util> module and will be much better
performant because it won't need any additional run-time checks, because
C<Map> is the immutable version of C<Hash> in Perl 6.

=head1 PORTING CAVEATS

Functions that pertain to the unique implementation of Perl 5 hashes, have
B<not> been ported.  These include:

    hash_seed hash_value hv_store bucket_stats
    bucket_info bucket_array hash_traversal_mask

Also field hashes (the tools to create inside-out objects) have not been
ported is these were deemed rather useless in the Perl 6 environment where
everything is a true object.  This pertains to the functions:

    fieldhash fieldhashes

Since the concept of references does not exist as such in Perl 6, it didn't
make sense to separately port the "_ref" versions of the subroutines.  They
are however available as aliases to the non "_ref" versions::

    lock_hashref unlock_hashref lock_hashref_recurse unlock_hashref_recurse
    lock_ref_keys lock_ref_keys_plus unlock_ref_keys
    lock_ref_value unlock_ref_value
    hashref_locked hashref_unlocked

=head1 FUNCTIONS

=head2 lock_keys HASH, [KEYS]

    lock_keys(%hash);
    lock_keys(%hash, @keys);

Restricts the given %hash's set of keys to @keys.  If @keys is not
given it restricts it to its current keyset.  No more keys can be
added. C<:delete> and C<:exists> will still work, but will not alter
the set of allowed keys.  Returns the hash it worked on.

=head2 unlock_keys HASH

    unlock_keys(%hash);

Removes the restriction on the %hash's keyset.

B<Note> that if any of the values of the hash have been locked they will not
be unlocked after this sub executes.  Returns the hash it worked on.

=head2 lock_keys_plus HASH, KEYS

    lock_keys_plus(%hash,@additional_keys)

Similar to C<lock_keys>, with the difference being that the optional key list
specifies keys that may or may not be already in the hash. Essentially this is
an easier way to say

    lock_keys(%hash,@additional_keys,%hash.keys);

=head2 lock_value HASH, KEY

    lock_value(%hash, $key);

Locks the value for an individual key of a hash.  The value of a locked key
cannot be changed.  Unless %hash has already been locked the key/value could
be deleted regardless of this setting.  Returns the hash on which it operated.

=head2 unlock_value HASH, KEY

    unlock_value(%hash, $key);

Unlocks the value for an individual key of a hash.  Returns the hash on
which it operated.

=head2 lock_hash HASH

    lock_hash(%hash);

Locks an entire hash, making all keys and values read-only.  No value can be
changed, no keys can be added or deleted.  Returns the hash it operated on.
If you only want to lock a hash only once after it has been initialized, it's
better to make it a C<Map>:

    my %hash is Map = foo => 42, bar => 23;

This will have the same effect as C<lock_hash>, but will be much more
performant as no extra overhead is needed for checking access at runtime.

=head2 unlock_hash HASH

    unlock_hash(%hash);

Does the opposite of C<lock_hash>.  All keys and values are made writable.
All values can be changed and keys can be added and deleted.  Returns the
hash it operated on.

=head2 lock_hash_recurse HASH

    lock_hash_recurse(%hash);

Locks an entire hash and any hashes it references recursively, making all
keys and values read-only. No value can be changed, no keys can be added or
deleted.  Returns the hash it originally operated on.

This method B<only> recurses into hashes that are referenced by another hash.
Thus a Hash of Hashes (HoH) will all be restricted, but a Hash of Arrays of
Hashes (HoAoH) will only have the top hash restricted.

=head2 unlock_hash_recurse HASH

    unlock_hash_recurse(%hash);

Does the opposite of lock_hash_recurse().  All keys and values are made
writable.  All values can be changed and keys can be added and deleted.
Returns the hash it originally operated on.

Identical recursion restrictions apply as to C<lock_hash_recurse>.

=head2 hash_locked HASH

    say "Hash is locked!" if hash_locked(%hash);

Returns true if the hash and/or its keys are locked.

=head2 hash_unlocked HASH

    say "Hash is unlocked!" if hash_unlocked(%hash);

Returns true if the hash and/or its keys are B<not> locked.

=head2 legal_keys HASH

    my @legal = legal_keys(%hash);

Returns the list of the keys that are legal in a restricted hash.  In the
case of an unrestricted hash this is identical to calling C<%hash.keys>.

=head2 hidden_keys HASH

    my @hidden = hidden_keys(%hash);

Returns the list of the keys that are legal in a restricted hash but do not
have a value associated to them. Thus if 'foo' is a "hidden" key of the
%hash it will return False for both C<defined> and C<:exists> tests.

In the case of an unrestricted hash this will return an empty list.

=head2 all_keys HASH, VISIBLE, HIDDEN

    all_keys(%hash,@visible,@hidden);

Populates the arrays @visible with the all the keys that would pass
an C<exists> tests, and populates @hidden with the remaining legal
keys that have not been utilized.  Returns the hash it operated on.

=head1 SEE ALSO

L<Scalar::Util>, L<List::Util>

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/Hash-Util . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

Re-imagined from the Perl 5 version as part of the CPAN Butterfly Plan. Perl 5
version originally developed by the Perl 5 Porters, subsequently maintained
by Steve Hay.

=end pod

# vim: ft=perl6 expandtab sw=4
