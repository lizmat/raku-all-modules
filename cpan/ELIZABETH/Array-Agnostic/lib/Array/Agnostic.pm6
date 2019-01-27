use v6.c;

sub is-container(\it) is export { it.VAR.^name ne it.^name }

role Array::Agnostic:ver<0.0.6>:auth<cpan:ELIZABETH>
  does Positional   # .AT-POS and friends
  does Iterable     # .iterator, basically
{

#--- These methods *MUST* be implemented by the consumer -----------------------
    method AT-POS($)     is raw { ... }
    method BIND-POS($,$) is raw { ... }
    method EXISTS-POS($)        { ... }
    method DELETE-POS($)        { ... }
    method elems()              { ... }

#--- Internal Iterator classes that need to be specified here ------------------
    my class Iterate does Iterator {
        has $.backend;
        has $.end;
        has $.index = -1;

        method pull-one() is raw {
            $!index < $!end
              ?? $!backend.AT-POS(++$!index)
              !! IterationEnd
        }
    }

    my class KV does Iterator {
        has $.backend;
        has $.end;
        has $.index = -1;
        has int $on;

        method pull-one() is raw {
            $on++ %% 2
              ?? $!index < $!end            # on the key now
                ?? ++$!index
                !! IterationEnd
              !! $!backend.AT-POS($!index)  # on the value now
        }
    }

#--- Positional methods that *MAY* be implemented by the consumer --------------
    method CLEAR() {
        self.DELETE-POS($_) for (^$.elems).reverse;
    }

    method ASSIGN-POS($pos, \value) is raw {
        self.AT-POS($pos) = value;
    }

    method STORE(*@values, :$initialize) {
        self.CLEAR;
        self.ASSIGN-POS($_,@values.AT-POS($_)) for ^@values;
        self
    }

#--- Array methods that *MAY* be implemented by the consumer -------------------
    method new(::?CLASS:U: **@values is raw) {
        self.CREATE.STORE(@values)
    }
    method iterator() { Iterate.new( :backend(self), :$.end ) }

    method end()    { $.elems - 1 }
    method keys()   { Seq.new( (^$.elems).iterator ) }
    method values() { Seq.new( self.iterator ) }
    method pairs()  { (^$.elems).map: { $_ => self.AT-POS($_) } }
    method shape()  { (*,) }

    method kv() { Seq.new( KV.new( :backend(self), :$.end ) ) }

    method list()  { List .from-iterator(self.iterator) }
    method Slip()  { Slip .from-iterator(self.iterator) }
    method List()  { List .from-iterator(self.iterator) }
    method Array() { Array.from-iterator(self.iterator) }

    method !append(@values) {
        self.ASSIGN-POS(self.elems,$_) for @values;
        self
    }
    method append(+@values is raw) { self!append(@values) }
    method push( **@values is raw) { self!append(@values) }
    method pop() {
        if self.elems -> \elems {
            self.DELETE-POS(elems - 1)
        }
        else {
            [].pop  # standard behaviour on empty arrays
        }
    }

    method !prepend(@values) {
        self.move-indexes-up(+@values);
        self.ASSIGN-POS($_,@values.AT-POS($_)) for ^@values;
        self
    }
    method prepend( +@values is raw) { self!prepend(@values) }
    method unshift(**@values is raw) { self!prepend(@values) }
    method shift() {
        if self.elems -> \elems {
            my \value = self.AT-POS(0)<>;
            self.move-indexes-down(1);
            value
        }
        else {
            [].shift  # standard behaviour on empty arrays
        }
    }

    method gist() { '[' ~ self.Str ~ ']' }
    method Str()  { self.values.map( *.Str ).join(" ") }
    method perl() {
        self.perlseen(self.^name, {
          ~ self.^name
          ~ '.new('
          ~ self.map({$_<>.perl}).join(',')
          ~ ',' x (self.elems == 1 && self.AT-POS(0) ~~ Iterable)
          ~ ')'
        })
    }

    method splice() { X::NYI.new( :feature<splice> ).throw }
    method grab()   { X::NYI.new( :feature<grab>   ).throw }

# -- Internal subroutines and methods that *MAY* be implemented ----------------

    # Move indexes up for the number of positions given, optionally from the
    # given given position (defaults to start). Removes the original positions.
    method move-indexes-up($up, $start = 0 --> Nil) {
        for ($start ..^ $.elems).reverse {
            if self.EXISTS-POS($_) {
                is-container(my \value = self.DELETE-POS($_))
                  ?? self.ASSIGN-POS($_ + $up, value)
                  !! self.BIND-POS(  $_ + $up, value);
            }
        }
    }

    # Move indexes down for the number of positions given, optionally from the
    # given position (which defaults to the number of positions to move down).
    # Removes original positions.
    method move-indexes-down($down, $start = $down --> Nil) {
        for ($start ..^ $.elems).list -> $from {
            my $to = $from - $down;
            if self.EXISTS-POS($from) {
                my \value = self.DELETE-POS($from);  # something to move
                if is-container(value) {
                    self.DELETE-POS($to);            # could have been bound
                    self.ASSIGN-POS($to, value);
                }
                else {
                    self.BIND-POS($to, value);       # don't care what it was
                }
            }
            else {
                self.DELETE-POS($to);                # nothing to move
            }
        }
    }
}

=begin pod

=head1 NAME

Array::Agnostic - be an array without knowing how

=head1 SYNOPSIS

  use Array::Agnostic;
  class MyArray does Array::Agnostic {
      method AT-POS()     { ... }
      method BIND-POS()   { ... }
      method DELETE-POS() { ... }
      method EXISTS-POS() { ... }
      method elems()      { ... }
  }

  my @a is MyArray = 1,2,3;

=head1 DESCRIPTION

This module makes an C<Array::Agnostic> role available for those classes that
wish to implement the C<Positional> role as an C<Array>.  It provides all of
the C<Array> functionality while only needing to implement 5 methods:

=head2 Required Methods

=head3 method AT-POS

  method AT-POS($position) { ... }  # simple case

  method AT-POS($position) { Proxy.new( FETCH => { ... }, STORE => { ... } }

Return the value at the given position in the array.  Must return a C<Proxy>
that will assign to that position if you wish to allow for auto-vivification
of elements in your array.

=head3 method BIND-POS

  method BIND-POS($position, $value) { ... }

Bind the given value to the given position in the array, and return the value.

=head3 method DELETE-POS

  method DELETE-POS($position) { ... }

Mark the element at the given position in the array as absent (make
C<EXISTS-POS> return C<False> for this position).

=head3 method EXISTS-POS

  method EXISTS-POS($position) { ... }

Return C<Bool> indicating whether the element at the given position exists
(aka, is B<not> marked as absent).

=head3 method elems

  method elems(--> Int:D) { ... }

Return the number of elements in the array (defined as the index of the
highest element + 1).

=head2 Optional Methods (provided by role)

You may implement these methods out of performance reasons yourself, but you
don't have to as an implementation is provided by this role.  They follow the
same semantics as the methods on the
L<Array object|https://docs.perl6.org/type/Array>.

In alphabetical order:
C<append>, C<Array>, C<ASSIGN-POS>, C<end>, C<gist>, C<grab>, C<iterator>, 
C<keys>, C<kv>, C<list>, C<List>, C<new>, C<pairs>, C<perl>, C<pop>, 
C<prepend>, C<push>, C<shape>, C<shift>, C<Slip>, C<STORE>, C<Str>, C<splice>, 
C<unshift>, C<values>

=head2 Optional Internal Methods (provided by role)

These methods may be implemented by the consumer for performance reasons.

=head3 method CLEAR

  method CLEAR(--> Nil) { ... }

Reset the array to have no elements at all.  By default implemented by
repeatedly calling C<DELETE-POS>, which will by all means, be very slow.
So it is a good idea to implement this method yourself.

=head3 method move-indexes-up

  method move-indexes-up($up, $start = 0) { ... }

Add the given value to the B<indexes> of the elements in the array, optionally
starting from a given start index value (by default 0, so all elements of the
array will be affected).  This functionality is needed if you want to be able
to use C<shift>, C<unshift> and related functions.

=head3 method move-indexes-down

  method move-indexes-down($down, $start = $down) { ... }

Subtract the given value to the B<indexes> of the elements in the array,
optionally starting from a given start index value (by default the same as
the number to subtract, so that all elements of the array will be affected.
This functionality is needed if you want to be able to use C<shift>,
C<unshift> and related functions.

=head2 Exported subroutines

=head3 sub is-container

  my $a = 42;
  say is-container($a);  # True
  say is-container(42);  # False

Returns whether the given argument is a container or not.  This can be handy
for situations where you want to also support binding, B<and> allow for
methods such as C<shift>, C<unshift> and related functions.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/Array-Agnostic .
Comments and Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: ft=perl6 expandtab sw=4
