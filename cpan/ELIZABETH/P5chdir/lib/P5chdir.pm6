use v6.c;

unit module P5chdir:ver<0.0.5>:auth<cpan:ELIZABETH>;

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

=head2 ORIGINAL PERL 5 DOCUMENTATION

    chdir EXPR
    chdir FILEHANDLE
    chdir DIRHANDLE
    chdir   Changes the working directory to EXPR, if possible. If EXPR is
            omitted, changes to the directory specified by $ENV{HOME}, if set;
            if not, changes to the directory specified by $ENV{LOGDIR}. (Under
            VMS, the variable $ENV{SYS$LOGIN} is also checked, and used if it
            is set.) If neither is set, "chdir" does nothing. It returns true
            on success, false otherwise. See the example under "die".

            On systems that support fchdir(2), you may pass a filehandle or
            directory handle as the argument. On systems that don't support
            fchdir(2), passing handles raises an exception.

=head2 PORTING CAVEATS

In Perl 6, C<chdir> only changes the C<$*CWD> dynamic variable.  It does
B<not> actually change the default directory from the OS's point of view.
This is done this way, because there is no concept of a "default directory
per OS thread".  And since Perl 6 does not fork, but only does threading,
it was felt that the "current directory" concept should be in the C<$*CWD>
dynamic variable, which can be lexically scoped, and thus can be thread-safe.

=head1 DESCRIPTION

This module tries to mimic the behaviour of the C<chdir> function of Perl 5
as closely as possible.

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
