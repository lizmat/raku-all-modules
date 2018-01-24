use v6.c;
unit class P5lcfirst:ver<0.0.1>;

proto sub lcfirst(|) is export {*}
multi sub lcfirst(--> Str:D) {
    lcfirst(CALLER::<$_>)
}
multi sub lcfirst(Str() $string --> Str:D) {
    $string
      ?? $string.substr(0,1).lc ~ $string.substr(1)
      !! $string
}

=begin pod

=head1 NAME

P5lcfirst - Implement Perl 5's lcfirst() built-in

=head1 SYNOPSIS

  use P5lcfirst;

  say lcfirst "FOOBAR"; # fOOBAR

  with "ZIPPO" {
      say lcfirst;  # zIPPO
  }

=head1 DESCRIPTION

This module tries to mimic the behaviour of the C<lcfirst> of Perl 5 as closely as
possible.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5lcfirst . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
