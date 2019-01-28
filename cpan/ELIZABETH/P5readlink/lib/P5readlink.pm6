use v6.c;

unit module P5readlink:ver<0.0.4>:auth<cpan:ELIZABETH>;

proto sub readlink(|) is export {*}
multi sub readlink(--> Str:D) {
    readlink(CALLERS::<$_>)
}
multi sub readlink(Str() $path --> Str:D) {
    use nqp;  # readlink functionality only exposed as nqp ops
    nqp::stat($path,nqp::const::STAT_EXISTS) && nqp::fileislink($path)
      ?? nqp::readlink($path)
      !! Nil
}

=begin pod

=head1 NAME

P5readlink - Implement Perl 5's readlink() built-in

=head1 SYNOPSIS

  use P5readlink;

  say readlink("foobar"); # string if symlink, Nil if not

  with "foobar" {
      say readlink; # string if symlink, Nil if not
  }

=head1 DESCRIPTION

This module tries to mimic the behaviour of the C<readlink> of Perl 5 as
closely as possible.

=head1 ORIGINAL PERL 5 DOCUMENTATION

    readlink EXPR
    readlink
            Returns the value of a symbolic link, if symbolic links are
            implemented. If not, raises an exception. If there is a system
            error, returns the undefined value and sets $! (errno). If EXPR is
            omitted, uses $_.

            Portability issues: "readlink" in perlport.

=head1 PORTING CAVEATS

Currently C<$!> is B<not> set when Nil is returned.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5readlink . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
