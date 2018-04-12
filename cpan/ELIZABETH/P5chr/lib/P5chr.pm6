use v6.c;
unit module P5chr:ver<0.0.3>;

proto sub chr(|) is export {*}
multi sub chr(--> Str:D) { chr CALLERS::<$_> }
multi sub chr(Int() $n is copy --> Str:D) {
    role InvalidChr { has $.ord }

    $n < 0
      ?? 0xfffd.chr
      !! 128 <= $n <= 255
        ?? "?" but InvalidChr($n)
        !! $n.chr
}

=begin pod

=head1 NAME

P5chr - Implement Perl 5's chr() built-in

=head1 SYNOPSIS

  use P5chr; # exports chr()

  my $a = 65;
  say chr $a;

  $_ = 65;
  say chr();      # bare chr may be compilation error to prevent P5isms in Perl 6

=head1 DESCRIPTION

This module tries to mimic the behaviour of the C<chr> of Perl 5 as closely as
possible.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5chr . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
