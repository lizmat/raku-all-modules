use v6.c;

module P5rand:ver<0.0.5>:auth<cpan:ELIZABETH> {
    use P5math;
    BEGIN trait_mod:<is>(&rand,:export);
}

=begin pod

=head1 NAME

P5rand - Implement Perl 5's rand() built-ins [DEPRECATED]

=head1 SYNOPSIS

  use P5rand;

  say rand;    # a number between 0 and 1

  say rand 42; # a number between 0 and 42

=head1 DESCRIPTION

This module tries to mimic the behaviour of the C<rand> built-in of Perl 5
as closely as possible.  It has been deprecated in favour of the C<P5math>
module, which exports C<rand> among many other math related functions.
Please use that module instead of this one.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5rand . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
