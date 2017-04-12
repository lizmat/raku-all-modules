use v6;
unit module UNIX::Daemonize;
use UNIX::Daemonize::NativeSymbols;
use NativeCall;

#=daemonize-self aliases do daemonize without program
sub daemonize-self(*%kwargs) is export {
    return daemonize(%kwargs);
}

sub daemonize(*@executable, Str :$cd, Str :$stderr='/dev/null', 
        Str :$stdout='/dev/null', :%ENV, Str :$pid-file,
        Bool :$repeat=False, Bool :$shell=False,
        ) is export {
    my $daemonize-self = !@executable;
    if $daemonize-self {
        fork-or-fail() && exit 0; # main thread exits, daemon will take its place
    } else {
        fork-or-fail() && return 0; # return to main thread
    };
    fail "Can't detach" if setsid() < 0;
    fork-or-fail() && exit 0;
    with %ENV {
        for %ENV.kv -> $k, $v {
            %*ENV{$k} = $v;
        }
    }
    chdir $cd with $cd;
    lockfile-create($pid-file) with $pid-file; 
    # if we daemonize ourselves, remove pidfile when exitting
    my $clean-after-finishing = $daemonize-self;
    END { if $clean-after-finishing {
        lockfile-remove("$pid-file") with $pid-file; 
    }; };

    fail "Can't detach" if setsid() < 0;  # not really necessary but it makes PID == PGID
    umask(0);
    ($*OUT,$*ERR,$*IN)».close;
    $*OUT = open($stdout, :w) or fail "Can't open $stdout for writing";
    $*ERR = open($stderr, :w) or fail "Can't open $stderr for writing";
    if $daemonize-self {
        return 0; 
    } else {
        run-main-command(:@executable, :$shell, :$repeat);
        lockfile-remove("$pid-file") with $pid-file;
        exit 0;
    }
}

sub run-main-command(:@executable, :$shell, :$repeat) {
    if $repeat {
        loop {
            if !$shell {
                run |@executable, :out($*OUT), :err($*ERR);
            } else {
                shell @executable.join(' ');
            }
        }
    } else {
        if !$shell {
            run |@executable, :out($*OUT), :err($*ERR);
        } else {
            shell @executable.join(' ');
        }
    }
}

#=returns False if process doesn't exist or 
#=we don't have permissions to send signals to it
sub accepts-signals(Int $pid --> Bool ) is export {
    kill($pid, 0) == 0 ?? True !! False;
}

#=tries to terminate all processes from given Process Group
#=Int $pgid - PGID of processes to kill
#=Bool :$force - SIGKILL is sent instead of SIGTERM
#=Bool :$verbose - be verbose
#=Num :$timeout - NOT IMPLEMENTED! fails if after $timeout seconds some processes still alive 
sub terminate-process-group(Int $pgid, Bool :$force, Bool :$verbose, Num :$timeout) is export {
    "Terminating PG $pgid".say if $verbose;;
    my $sig-num = $force ?? SignalNumbers::KILL !! SignalNumbers::TERM;
    while pg-alive($pgid) {
        kill(-abs($pgid),$sig-num);   
    }
}

#=terminates whole process group connected with pid-file, removes lockfile if succeeds
sub terminate-process-group-from-file(Str $pid-file, Bool :$force, Bool :$verbose, Num :$timeout) is export {
    if lockfile-valid($pid-file) {
        "Found valid lockfile, terminating".say if $verbose;
        my $pid = slurp($pid-file).Int;
        terminate-process-group($pid, :$force, :$timeout);
        return lockfile-remove($pid-file) unless pg-alive($pid);
        fail "some processes still alive";
    } else {
        fail "No valid lockfile";    
    }
}

#=alive if either kill 0 ok, or sending signals not permitted
sub is-alive(Int $pid) is export {

    # TODO: add real osx support to whole module
    if $*KERNEL.name eq 'darwin' {
        if kill($pid, 0) == 0 or cglobal('libc.dylib', 'errno', int32) == 1 {
            return True;
        } else {
            return False;
        }
    } else {
        if kill($pid, 0) == 0 or cglobal('libc.so.6', 'errno', int32) == 1 {
            return True;
        } else {
            return False;
        }
    }
}

#=any process from process group alive?
sub pg-alive(Int $pgid) is export(:ALL) {
    is-alive(-abs($pgid));
}

sub fork-or-fail is export(:ALL) {
    my $rv = fork();
    return $rv if $rv >= 0; 
    fail "Can't fork";
}

sub pid-from-pidfile(Str $pid-file --> Int ) is export(:ALL) {
    fail ("File doesn't exist") unless $pid-file.IO.e;
    return slurp($pid-file).Int;
}

sub lockfile-valid($pid-file) is export(:ALL) {
    return False unless $pid-file.IO.e;
    my $pid = pid-from-pidfile($pid-file);
    return is-alive($pid);
}

sub lockfile-remove($pid-file) is export(:ALL) {
    "Removing PID lockfile".say;
    try { 
        $pid-file.IO.unlink;
    }
}

sub lockfile-create($pid-file) is export(:ALL) {
    my $valid =  lockfile-valid($pid-file);
    fail ("Valid lockfile exists") if $valid;
    fail ("Can't write to file $pid-file") unless $pid-file.IO.spurt($*PID);
    return True;
}

=begin pod

=head1 NAME

(WIP) UNIX::Daemonize - run external commands or Perl6 code as daemons

=head1 SYNOPSIS

  use UNIX::Daemonize;
  daemonize(<xcowsay mooo>, :repeat, :pid-file</var/lock/mycow>);

Then, if you're not a fan of cows repeatedly jumping at you 

  terminate-process-group-from-file("/var/lock/mycow");

This daemon is actually 2 processes: perl6 script you ran above, and external command 'xcowsay', 'mooo' 
both same process group. That's why we're terminating whole PG

You can also daemonize Perl6 code to be run after daemonize call (note no positional arguments):
    
  use UNIX::Daemonize;
  daemonize(:pid-file</var/lock/mycow>);
  Promise.in(15).then({exit 0;});
  loop { qq:x/xcowsay moo/; }

C<daemonize> binary provided too – you can daemonize directly from shell:

  $ daemonize --pid-file='lock' --repeat xcowsay moo
  $ kill -15 -`cat lock` && rm lock

Negative PID kills whole PGID

=head1 DESCRIPTION

UNIX::Daemonize is configurable daemonizing tool written in Perl 6.

Requirements:

=item POSIX compliant OS (fork, umask, setsid …)
=item Perl6
=item xcowsay to run demo above :)

(WIP)

=head1 BUGS / CONTRIBUTING

Repo can be found L<https://github.com/hipek8/p6-UNIX-Daemonize>. Feel free to contribute.

Let me know if you find any bug (not that I'll be surprised…). If you can correct it, PR is our friend.

KNOWN ISSUES:

=item stdout/stderr redirects ignored when running shell set to True, use shell redirects
=item tests fail for osx, investigate and add to travis

=head1 AUTHOR

Paweł Szulc <pawel_szulc@onet.pl>

=head1 COPYRIGHT AND LICENSE

Copyright 2016 Paweł Szulc

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
