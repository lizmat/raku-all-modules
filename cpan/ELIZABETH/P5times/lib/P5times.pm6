use v6.c;

unit module P5times:ver<0.0.5>:auth<cpan:ELIZABETH>;

sub times() is export {
    use nqp;
    nqp::getrusage(my int @rusage);
    (
      nqp::atpos_i(@rusage, nqp::const::RUSAGE_UTIME_SEC) * 1000000
        + nqp::atpos_i(@rusage, nqp::const::RUSAGE_UTIME_MSEC),
      nqp::atpos_i(@rusage, nqp::const::RUSAGE_STIME_SEC) * 1000000
        + nqp::atpos_i(@rusage, nqp::const::RUSAGE_STIME_MSEC),
      0,
      0
    )
}

=begin pod

=head1 NAME

P5times - Implement Perl 5's times() built-in

=head1 SYNOPSIS

  use P5times; # exports times()

  ($user,$system,$cuser,$csystem) = times;

=head1 DESCRIPTION

This module tries to mimic the behaviour of the C<times> function of Perl 5
as closely as possible.

=head1 ORIGINAL PERL 5 DOCUMENTATION

    times   Returns a four-element list giving the user and system times in
            seconds for this process and any exited children of this process.

                ($user,$system,$cuser,$csystem) = times;

            In scalar context, "times" returns $user.

            Children's times are only included for terminated children.

            Portability issues: "times" in perlport.

=head1 PORTING CAVEATS

=head2 Child process information

There is currently no way to obtain the usage information of child processes.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5times . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
