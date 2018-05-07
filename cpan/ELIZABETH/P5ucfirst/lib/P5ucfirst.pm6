use v6.c;

module P5ucfirst:ver<0.0.4>:auth<cpan:ELIZABETH> {
    use P5lcfirst;
    BEGIN trait_mod:<is>(&ucfirst,:export);
}

=begin pod

=head1 NAME

P5ucfirst - Implement Perl 5's ucfirst() built-in [DEPRECATED]

=head1 SYNOPSIS

  use P5ucfirst;

  say ucfirst "foobar"; # Foobar

  with "zippo" {
      say ucfirst;  # Zippo
  }

=head1 DESCRIPTION

This module tries to mimic the behaviour of the C<ucfirst> of Perl 5 as closely as
possible.  It has been deprecated in favour of the C<P5lcfirst> module, which exports
both C<ucfirst> and C<lcfirst>.  Please use that module instead of this one.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5ucfirst . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
