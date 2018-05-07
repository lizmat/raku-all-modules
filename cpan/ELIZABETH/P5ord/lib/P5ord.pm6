use v6.c;

module P5ord:ver<0.0.5>:auth<cpan:ELIZABETH> {
    use P5chr;
    BEGIN trait_mod:<is>(&ord,:export);
}

=begin pod

=head1 NAME

P5ord - Implement Perl 5's ord() built-in [DEPRECATED]

=head1 SYNOPSIS

  use P5ord; # exports ord()

  my $a = "A";
  say ord $a;

  $_ = "A";
  say ord();      # bare ord may be compilation error to prevent P5isms in Perl 6

=head1 DESCRIPTION

This module tries to mimic the behaviour of the C<ord> of Perl 5 as closely as
possible.  It has been deprecated in favour of the C<P5chr> module, which exports
both C<ord> and C<chr>.  Please use that module instead of this one.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5ord . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
