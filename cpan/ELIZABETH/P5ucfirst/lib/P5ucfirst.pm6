use v6.c;
unit class P5ucfirst:ver<0.0.2>;

proto sub ucfirst(|) is export {*}
multi sub ucfirst(--> Str:D) {
    ucfirst(CALLERS::<$_>)
}
multi sub ucfirst(Str() $string --> Str:D) {
    $string
      ?? $string.substr(0,1).uc ~ $string.substr(1)
      !! $string
}

=begin pod

=head1 NAME

P5ucfirst - Implement Perl 5's ucfirst() built-in

=head1 SYNOPSIS

  use P5ucfirst;

  say ucfirst "foobar"; # Foobar

  with "zippo" {
      say ucfirst;  # Zippo
  }

=head1 DESCRIPTION

This module tries to mimic the behaviour of the C<ucfirst> of Perl 5 as closely as
possible.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5ucfirst . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
