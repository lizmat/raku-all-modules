use v6.c;

role Hash-with:ver<0.0.2>:auth<cpan:ELIZABETH>[&mapper] {
    method AT-KEY(\key)              { nextwith(mapper(key))        }
    method EXISTS-KEY(\key)          { nextwith(mapper(key))        }
    method DELETE-KEY(\key)          { nextwith(mapper(key))        }
    method STORE_AT_KEY(\key,\value) { nextwith(mapper(key), value) }
    method BIND-KEY(\key,\value)     { nextwith(mapper(key), value) }
}

role Hash-lc {
    method AT-KEY(\key)              { nextwith(key.lc)        }
    method EXISTS-KEY(\key)          { nextwith(key.lc)        }
    method DELETE-KEY(\key)          { nextwith(key.lc)        }
    method STORE_AT_KEY(\key,\value) { nextwith(key.lc, value) }
    method BIND-KEY(\key,\value)     { nextwith(key.lc, value) }
}

role Hash-uc {
    method AT-KEY(\key)              { nextwith(key.uc)        }
    method EXISTS-KEY(\key)          { nextwith(key.uc)        }
    method DELETE-KEY(\key)          { nextwith(key.uc)        }
    method STORE_AT_KEY(\key,\value) { nextwith(key.uc, value) }
    method BIND-KEY(\key,\value)     { nextwith(key.uc, value) }
}

=begin pod

=head1 NAME

Hash-with - Roles for automatically mapping keys in hashes

=head1 SYNOPSIS

  use Hash-with;

  my %h1 does Hash-lc = A => 42;             # map all keys to lowercase
  say %h1<a>;    # 42

  my %h2 does Hash-uc = a => 42;             # map all keys to uppercase
  say %h2<A>;    # 42

  sub ordered($a) { $a.comb.sort.join }
  my %h3 does Hash-with[&ordered] = oof => 42;  # sort characters of key
  say %h3<foo>;  # 42

=head1 DESCRIPTION

Hash::with provides several C<role>s that can be mixed in with a C<Hash>.

=head2 Hash-lc

The role that will convert all keys of a hash to their B<lowercase> equivalent
before being used to access the hash.

  my %h1 does Hash-lc = A => 42;             # map all keys to lowercase
  say %h1<a>;    # 42

This is in fact an optimized version of C<does Hash-with[&lc]>.

=head2 Hash-uc

The role that will convert all keys of a hash to their B<uppercase> equivalent
before being used to access the hash.

  my %h2 does Hash-uc = a => 42;             # map all keys to uppercase
  say %h2<A>;    # 42

This is in fact an optimized version of C<does Hash-with[&uc]>.

=head2 Hash-with

The role that will convert all keys of a hash according to a C<mapper> function
before being used to access the hash.

  sub ordered($a) { $a.comb.sort.join }
  my %h3 does Hash-with[&ordered] = oof => 42;  # order all keys
  say %h3<foo>;  # 42

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/Hash-with . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: ft=perl6 expandtab sw=4
