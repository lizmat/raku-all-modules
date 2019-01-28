use v6.c;

unit module P5sleep:ver<0.0.7>:auth<cpan:ELIZABETH>;

proto sub sleep(|) is export {*}
multi sub sleep() { &CORE::sleep() }
multi sub sleep(Int() $seconds) {
    ($seconds - &CORE::sleep-timer($seconds)).Int
}

=begin pod

=head1 NAME

P5sleep - Implement Perl 5's sleep() built-in

=head1 SYNOPSIS

  use P5sleep; # exports sleep()

=head1 DESCRIPTION

This module tries to mimic the behaviour of the C<sleep> function of Perl 5
as closely as possible.

=head1 ORIGINAL PERL 5 DOCUMENTATION

    sleep EXPR
    sleep   Causes the script to sleep for (integer) EXPR seconds, or forever
            if no argument is given. Returns the integer number of seconds
            actually slept.

            May be interrupted if the process receives a signal such as
            "SIGALRM".

                eval {
                    local $SIG{ALARM} = sub { die "Alarm!\n" };
                    sleep;
                };
                die $@ unless $@ eq "Alarm!\n";

            You probably cannot mix "alarm" and "sleep" calls, because "sleep"
            is often implemented using "alarm".

            On some older systems, it may sleep up to a full second less than
            what you requested, depending on how it counts seconds. Most
            modern systems always sleep the full amount. They may appear to
            sleep longer than that, however, because your process might not be
            scheduled right away in a busy multitasking system.

            For delays of finer granularity than one second, the Time::HiRes
            module (from CPAN, and starting from Perl 5.8 part of the standard
            distribution) provides usleep(). You may also use Perl's
            four-argument version of select() leaving the first three
            arguments undefined, or you might be able to use the "syscall"
            interface to access setitimer(2) if your system supports it. See
            perlfaq8 for details.

            See also the POSIX module's "pause" function.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5sleep . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
