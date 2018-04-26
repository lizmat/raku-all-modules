use v6.c;

unit module P5chdir:ver<0.0.1>:auth<cpan:ELIZABETH>;

proto sub chdir(|) is export {*}
multi sub chdir(--> Bool:D) {
    with %*ENV<HOME> -> $home {
        chdir($home)
    }
    else {
        with %*ENV<LOGDIR> -> $logdir {
            chdir($logdir)
        }
        else {
            False
        }
    }
}
multi sub chdir(IO::Handle:D $handle --> Bool:D) {
    chdir($handle.path.parent)
}
multi sub chdir(Str() $s --> Bool:D) {
    so &CORE::chdir($s)
}

=begin pod

=head1 NAME

P5chdir - Implement Perl 5's chdir() built-in

=head1 SYNOPSIS

  use P5chdir;

  say "switched" if chdir; # switched to HOME or LOGDIR

  say "switched" if chdir("lib");

=head1 DESCRIPTION

This module tries to mimic the behaviour of the C<chdir> of Perl 5 as closely
as possible.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5chdir . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: ft=perl6 expandtab sw=4
