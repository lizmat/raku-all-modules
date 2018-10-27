use v6;
use Test;
use UNIX::Daemonize :ALL;
use Test::When <author>;

my $pid-lock = ".tmp.lock";
my $program-file = 'daemon.p6';
my $program-code = qq:to/EOF/;
#!/usr/bin/env perl6
use v6;
use UNIX::Daemonize;
daemonize(:pid-file<$pid-lock>);
sleep 3;
EOF

#=simulates p6 daemon run from the shell
subtest {
    ENTER { $program-file.IO.spurt($program-code); }
    LEAVE { $program-file.IO.unlink; }
    diag "Trying to run command";
    shell "perl6 -Ilib\/ $program-file";
    diag "Command run";
    sleep 1;
    ok lockfile-valid($pid-lock);
    my $pid = pid-from-pidfile($pid-lock);
    ok is-alive($pid);
    sleep 3;
    nok is-alive($pid);
    nok $pid-lock.IO.e;
}, "Daemon runs and exits, cleans up lockfile";

done-testing;
