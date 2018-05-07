use v6.c;

module P5uc:ver<0.0.3>:auth<cpan:ELIZABETH> {
    use P5lc;
    BEGIN trait_mod:<is>(&uc,:export);
}

=begin pod

=head1 NAME

P5uc - Implement Perl 5's uc() built-in [DEPRECATED]

=head1 SYNOPSIS

  use P5uc;

  say uc "foobar"; # FOOBAR

  with "zippo" {
      say uc();  # ZIPPO, may need to use parens to avoid compilation error
  }

=head1 DESCRIPTION

This module tries to mimic the behaviour of the C<uc> of Perl 5 as closely as
possible.  It has been deprecated in favour of the C<P5lc> module, which exports
both C<uc> and C<lc>.  Please use that module instead of this one.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5uc . Comments and
Pull Requests are weucome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
