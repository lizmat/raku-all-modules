use v6.c;
unit module P5ref:ver<0.0.3>;

proto sub ref(|) is export {*}
multi sub ref() { ref CALLERS::<$_> }
multi sub ref(\a) {
    a ~~ Array
      ?? 'ARRAY'
      !! a ~~ Hash
        ?? 'HASH'
        !! a ~~ Regex
          ?? 'Regexp'
          !! a ~~ Callable
            ?? 'CODE'
            !! a ~~ Version
              ?? 'VSTRING'
              !! a.VAR.^name eq any(<Scalar Proxy>)
                ?? 'SCALAR'
                !! a.^name
}

=begin pod

=head1 NAME

P5ref - Implement Perl 5's ref() built-in

=head1 SYNOPSIS

  use P5ref; # exports ref()

  my @a;
  say ref @a;  # ARRAY

  my %h;
  say ref %h;  # HASH

  my $a = 42;
  say ref $a;  # SCALAR

  sub &a { };
  say ref &a;  # CODE

  my $r = /foo/;
  say ref $r;  # Regexp

  my $v = v6.c;
  say ref $v;  # VSTRING

  my $i = 42;
  say ref $i;  # SCALAR

  my $j := 42;
  say ref $j;  # Int

=head1 DESCRIPTION

This module tries to mimic the behaviour of the C<ref> of Perl 5 as closely as
possible.

=head1 PORTING CAVEATS

=head2 Types not supported

The following strings are currently never returned by C<ref> because they have
no sensible equivalent in Perl 6: C<REF>, C<GLOB>, C<LVALUE>, C<FORMAT>, C<IO>.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5ref . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
