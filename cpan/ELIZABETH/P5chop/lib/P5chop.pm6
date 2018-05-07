use v6.c;

module P5chop:ver<0.0.4>:auth<cpan:ELIZABETH> {
    use P5chomp;
    BEGIN trait_mod:<is>(&chop,:export);
}

=begin pod

=head1 NAME

P5chop - Implement Perl 5's chop() built-in [DEPRECATED]

=head1 SYNOPSIS

  use P5chop; # exports chop()

  chop $a;
  chop @a;
  chop %h;
  chop($a,$b);
  chop();      # bare chop may be compilation error to prevent P5isms in Perl 6

=head1 DESCRIPTION

This module tries to mimic the behaviour of the C<chop> of Perl 5 as closely as
possible.  It has been deprecated in favour of the C<P5chomp> module, which
exports both C<chop> and C<chomp>.  Please use that module instead of this one.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5chop . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
