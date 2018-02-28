use v6.c;
unit class Sys::Hostname:ver<0.0.3>;

sub hostname() is export { gethostname.subst(/ \s | \0 /,'',:g) }

=begin pod

=head1 NAME

Sys::Hostname - Implement Perl 5's Sys::Hostname core module

=head1 SYNOPSIS

  use Sys::Hostname;
  $host = hostname;

=head1 DESCRIPTION

Obtain the system hostname as Perl 6 sees it.

All NULs, returns, and newlines are removed from the result.

=head1 PORTING CAVEATS

At present, the behaviour of the built-in C<gethostname> sub is used.  Any
bugs in its behaviour should be fixed there.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/Sys-Hostname . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Originally developed by David Sundstrom and Greg Bacon.  Re-imagined from Perl 5
as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
