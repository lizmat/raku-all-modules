use v6.c;
module P5oct:ver<0.0.4>:auth<cpan:ELIZABETH> {
    use P5hex;
    BEGIN trait_mod:<is>(&oct,:export);
}

=begin pod

=head1 NAME

P5oct - Implement Perl 5's oct() built-in [DEPRECATED]

=head1 SYNOPSIS

  use P5oct; # exports oct()

=head1 DESCRIPTION

This module tries to mimic the behaviour of the C<oct> of Perl 5 as closely as
possible.  It has been deprecated in favour of the C<P5hex> module, which
exports both C<oct> and C<hex>.  Please use that module instead of this one.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5oct . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
