use v6.c;

use Hash::Agnostic:ver<0.0.3>:auth<cpan:ELIZABETH>;

role Map::Agnostic:ver<0.0.1>:auth<cpan:ELIZABETH>
  does Hash::Agnostic
{
    has int $initialized;

#---- Methods supplied by Map::Agnostic needed by Hash::Agnostic ---------------
    method ASSIGN-KEY(\key, \value) {
        $initialized
          ?? (die "Cannot change key '{key}' in an immutable {self.^name}")
          !! self.INIT-KEY(key, value)
    }

    method BIND-KEY(\key, \value) {
        X::Bind.new(target => self.^name).throw;
    }

    method DELETE-KEY(\key) {
        die "Can not remove values from a {self.^name}";
    }

    multi method STORE(::?ROLE:D: \iterable, :$initialize!) {
        nextsame;
        $!initialized = 1;
        self
    }

#---- Methods needed by Map::Agnostic ------------------------------------------
    method INIT-KEY(\key, \value) { ... }

#---- Methods not allowed by Maps ----------------------------------------------
    method append(|) {
        die "Can not append values to a {self.^name}";
    }
    method grab(|) {
        die "Can not grab values from a {self.^name}";
    }
    method push(|) {
        die "Can not push values to a {self.^name}";
    }
}

=begin pod

=head1 NAME

Map::Agnostic - be a map without knowing how

=head1 SYNOPSIS

  use Map::Agnostic;
  class MyMap does Map::Agnostic {
      method INIT-KEY($key,$value) { ... }
      method AT-KEY($key)          { ... }
      method EXISTS-KEY($key)      { ... }
      method keys()                { ... }
  }

  my %m is MyMap = a => 42, b => 666;

  my %m is Map::Agnostic = ...;

=head1 DESCRIPTION

This module makes a C<Map::Agnostic> role available for those classes that
wish to implement the C<Associative> role as an immutable C<Map>.  It
provides all of the C<Map> functionality while only needing to implement
4 methods:

=head2 Required Methods

=head3 method INIT-KEY

  method INIT-KEY($key, $value) { ... }

Bind the given value to the given key in the map, and return the value.
This will only be called during initialization of the C<Map>.  The functioality
is the same as the C<BIND-KEY> method, but it will only be called at
initialization time, whereas C<BIND-KEY> can be called at any time and will
fail.

=head3 method AT-KEY

  method AT-KEY($key) { ... }

Return the value at the given key in the map.

=head3 method EXISTS-KEY

  method EXISTS-KEY($key) { ... }

Return C<Bool> indicating whether the key exists in the map.

=head3 method keys

  method keys() { ... }

Return the keys that currently exist in the map, in any order that is
most convenient.

=head2 Optional Methods (provided by role)

You may implement these methods out of performance reasons yourself, but you
don't have to as an implementation is provided by this role.  They follow the
same semantics as the methods on the
L<Map object|https://docs.perl6.org/type/Map>.

In alphabetical order:
C<elems>, C<end>, C<gist>, C<Hash>, C<iterator>, C<kv>, C<list>, C<List>,
C<new>, C<pairs>, C<perl>, C<Slip>, C<STORE>, C<Str>, C<values>

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/Map-Agnostic .
Comments and Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: ft=perl6 expandtab sw=4
