use v6;
use Test;
use UNIX::Daemonize :ALL;
# /sbin/init should be alive ;)
subtest {
    ok is-alive(1);
};

diag 'Testing on ' ~ $*KERNEL.name;
subtest {
    my $pidlockfile = ".tmp.lock";
    daemonize(<sleep 2>, :pid-file($pidlockfile));
    # file isn't created immediately, wait a bit
    sleep 0.5;
    my Int $pid = pid-from-pidfile($pidlockfile);
    ok is-alive($pid), "Still alive";
    sleep 2;
    nok pg-alive($pid), "Dead";
    dies-ok {pid-from-pidfile($pidlockfile)}, "No lock";
};

subtest {
    my $pidlockfile = ".tmp.lock";
    daemonize(<sleep 2>, :pid-file($pidlockfile), :repeat);
    # file isn't created immediately, wait a bit
    sleep 0.5;
    my Int $pid = pid-from-pidfile($pidlockfile);
    ok is-alive($pid), "Daemon still alive";
    sleep 2;
    ok is-alive($pid), "Daemon is restarted";
    
    terminate-process-group-from-file($pidlockfile);
    sleep 0.5;
    nok pg-alive($pid), "Now dead";
    nok $pidlockfile.IO.e;
}, "Repeat parameter works";

subtest {
    my $pidlockfile = ".tmp.lock";
    daemonize(<sleep 3>, :pid-file($pidlockfile));
    sleep 0.5;
    daemonize(«rm $pidlockfile», :pid-file($pidlockfile)); #, "This won't start";
    sleep 0.5;
    ok lockfile-valid($pidlockfile);
    sleep 3;
    nok lockfile-valid($pidlockfile);
}, "Won't create second daemon";

done-testing;
