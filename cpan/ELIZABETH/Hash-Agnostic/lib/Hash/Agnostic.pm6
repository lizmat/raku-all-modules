use v6.c;

role Hash::Agnostic:ver<0.0.4>:auth<cpan:ELIZABETH>
  does Associative  # .AT-KEY and friends
  does Iterable     # .iterator, basically
{

#--- These methods *MUST* be implemented by the consumer -----------------------
    method AT-KEY($)     is raw { ... }
    method BIND-KEY($,$) is raw { ... }
    method EXISTS-KEY($)        { ... }
    method DELETE-KEY($)        { ... }
    method keys()               { ... }

#--- Internal Iterator classes that need to be specified here ------------------
    my class KV does Iterator {
        has $.backend;
        has $.iterator;
        has $!key;

        method pull-one() is raw {
            with $!key {
                my $key = $!key;
                $!key  := Mu;
                $!backend.AT-KEY($key)          # on the value now
            }
            else {
                $!key := $!iterator.pull-one    # key or IterationEnd
            }
        }
    }

#--- Associative methods that *MAY* be implemented by the consumer -------------
    method CLEAR() {
        self.DELETE-KEY($_) for self.keys;
    }

    method ASSIGN-KEY($key, \value) is raw {
        self.AT-KEY($key) = value;
    }

    multi method STORE(::?ROLE:D: *@values, :$initialize) {
        self.CLEAR;
        self!STORE(@values);
        self
    }

    method !STORE(@values --> Int:D) {
        my $last := Mu;
        my int $found;

        for @values {
            if $_ ~~ Pair {
                self.ASSIGN-KEY(.key, .value);
                ++$found;
            }
            elsif $_ ~~ Failure {
                .throw
            }
            elsif !$last =:= Mu {
                self.ASSIGN-KEY($last, $_);
                ++$found;
                $last := Mu;
            }
            elsif $_ ~~ Map {
                $found += self!STORE([.pairs])
            }
            else {
                $last := $_;
            }
        }

        $last =:= Mu
          ?? $found
          !! X::Hash::Store::OddNumber.new(:$found, :$last).throw
    }

#--- Hash methods that *MAY* be implemented by the consumer -------------------
    method new(::?CLASS:U: **@values is raw) {
        self.CREATE.STORE(@values, :initialize)
    }
    method iterator() { self.pairs.iterator }

    method elems()  { self.keys.elems }
    method end()    { self.elems - 1 }
    method values() { self.keys.map: { self.AT-KEY($_) } }
    method pairs()  { self.keys.map: { Pair.new($_, self.AT-KEY($_) ) } }

    method kv() {
        Seq.new( KV.new( :backend(self), :iterator(self.keys.iterator ) ) )
    }

    method list()  {  List.from-iterator(self.iterator) }
    method Slip()  {  Slip.from-iterator(self.iterator) }
    method List()  {  List.from-iterator(self.iterator) }
    method Array() { Array.from-iterator(self.iterator) }
    method Hash()  {  Hash.new(self) }

    method !append(@values) { ... }
    method append(+@values is raw) { self!append(@values) }
    method push( **@values is raw) { self!append(@values) }

    method gist() {
        '{' ~ self.pairs.sort( *.key ).map( *.gist).join(", ") ~ '}'
    }
    method Str() {
        self.pairs.sort( *.key ).join(" ")
    }
    method perl() {
        self.perlseen(self.^name, {
          ~ self.^name
          ~ '.new('
          ~ self.pairs.sort( *.key ).map({$_<>.perl}).join(',')
          ~ ')'
        })
    }
}

=begin pod

=head1 NAME

Hash::Agnostic - be a hash without knowing how

=head1 SYNOPSIS

  use Hash::Agnostic;
  class MyHash does Hash::Agnostic {
      method AT-KEY($key)          { ... }
      method BIND-KEY($key,$value) { ... }
      method DELETE-KEY($key)      { ... }
      method EXISTS-KEY($key)      { ... }
      method keys()                { ... }
  }

  my %a is MyHash = a => 42, b => 666;

=head1 DESCRIPTION

This module makes an C<Hash::Agnostic> role available for those classes that
wish to implement the C<Associative> role as a C<Hash>.  It provides all of
the C<Hash> functionality while only needing to implement 5 methods:

=head2 Required Methods

=head3 method AT-KEY

  method AT-KEY($key) { ... }  # simple case

  method AT-KEY($key) { Proxy.new( FETCH => { ... }, STORE => { ... } }

Return the value at the given key in the hash.  Must return a C<Proxy> that
will assign to that key if you wish to allow for auto-vivification of elements
in your hash.

=head3 method BIND-KEY

  method BIND-KEY($key, $value) { ... }

Bind the given value to the given key in the hash, and return the value.

=head3 method DELETE-KEY

  method DELETE-KEY($key) { ... }

Remove the the given key from the hash and return its value if it existed
(otherwise return C<Nil>).

=head3 method EXISTS-KEY

  method EXISTS-KEY($key) { ... }

Return C<Bool> indicating whether the key exists in the hash.

=head3 method keys

  method keys() { ... }

Return the keys that currently exist in the hash, in any order that is
most convenient.

=head2 Optional Methods (provided by role)

You may implement these methods out of performance reasons yourself, but you
don't have to as an implementation is provided by this role.  They follow the
same semantics as the methods on the
L<Hash object|https://docs.perl6.org/type/Hash>.

In alphabetical order:
C<append>, C<ASSIGN-KEY>, C<elems>, C<end>, C<gist>, C<grab>, C<Hash>,
C<iterator>, C<kv>, C<list>, C<List>, C<new>, C<pairs>, C<perl>, C<push>,
C<Slip>, C<STORE>, C<Str>, C<values>

=head2 Optional Internal Methods (provided by role)

These methods may be implemented by the consumer for performance reasons.

=head3 method CLEAR

  method CLEAR(--> Nil) { ... }

Reset the array to have no elements at all.  By default implemented by
repeatedly calling C<DELETE-KEY>, which will by all means, be very slow.
So it is a good idea to implement this method yourself.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/Hash-Agnostic .
Comments and Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: ft=perl6 expandtab sw=4
