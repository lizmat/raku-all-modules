use v6.c;
unit module P5hex:ver<0.0.3>;

proto sub hex(|) is export {*}
multi sub hex() { hex CALLERS::<$_> }
multi sub hex(Str() $s) {
    $s ~~ / ^ <[a..f A..F 0..9]>* $ /
      ?? ($s ?? $s.parse-base(16) !! 0)
      !! +$s  # let numerification handle parse errors
}

=begin pod

=head1 NAME

P5hex - Implement Perl 5's hex() built-in

=head1 SYNOPSIS

  use P5hex; # exports hex()

=head1 DESCRIPTION

This module tries to mimic the behaviour of the C<hex> of Perl 5 as closely as
possible.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5hex . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
