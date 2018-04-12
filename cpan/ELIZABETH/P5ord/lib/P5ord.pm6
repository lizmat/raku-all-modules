use v6.c;
unit module P5ord:ver<0.0.3>;

proto sub ord(|) is export {*}
multi sub ord(--> Int:D) { CALLERS::<$_>.ord }
multi sub ord(Str() $s --> Int:D) { $s.ord }

=begin pod

=head1 NAME

P5ord - Implement Perl 5's ord() built-in

=head1 SYNOPSIS

  use P5ord; # exports ord()

  my $a = "A";
  say ord $a;

  $_ = "A";
  say ord();      # bare ord may be compilation error to prevent P5isms in Perl 6

=head1 DESCRIPTION

This module tries to mimic the behaviour of the C<ord> of Perl 5 as closely as
possible.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5ord . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
