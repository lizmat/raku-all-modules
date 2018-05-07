use v6.c;

unit module P5getpriority:ver<0.0.2>:auth<cpan:ELIZABETH>;

use NativeCall;

my sub getpriority(Int() $which, Int() $who) is export {
    sub _getpriority(int32, int32 --> int32) is native is symbol<getpriority> {*}
    my int32 $nwhich = $which;
    my int32 $nwho   = $who;
    _getpriority($nwhich, $nwho)
}

my sub setpriority(Int() $which, Int() $who, Int() $prio) is export {
    sub _setpriority(int32, int32, int32 --> int32) is native is symbol<setpriority> {*}
    my int32 $nwhich = $which;
    my int32 $nwho   = $who;
    my int32 $nprio  = $prio;
    _setpriority($nwhich, $nwho, $nprio)
}

my sub getppid(--> uint32) is native is export {*}

my sub getpgrp(--> uint32) is native is export {*}

my sub setpgrp(Int() $pid, Int() $pgid) is export {
    sub _setpgrp(int32, int32 --> int32) is native is symbol<setpgrp> {*}
    my int32 $npid  = $pid;
    my int32 $npgid = $pgid;
    _setpgrp($npid, $npgid)
}

=begin pod

=head1 NAME

P5getpriority - Implement Perl 5's getpriority() and associated built-ins

=head1 SYNOPSIS

    use P5getpriority; # exports getpriority, setpriority, getppid, getpgrp

    say "My parent process priority is &getpriority(0, getppid())";

    say "My process priority is &getpriority(0, $*PID)";

    say "My process group has priority &getpriority(1, getpgrp())";

    say "My user priority is &getpriority(2, $*USER)";

=head1 DESCRIPTION

This module tries to mimic the behaviour of the C<getpriority> and associated
functions of Perl 5 as closely as possible.  It exports by default:

    getpgrp getppid getpriority setpgrp setpriority

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5getpriority . Comments
and Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
