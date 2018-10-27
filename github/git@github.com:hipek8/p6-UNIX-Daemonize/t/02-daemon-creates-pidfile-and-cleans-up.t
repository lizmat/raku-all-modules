use v6;
use UNIX::Daemonize :ALL;
use Test;

subtest "Pidlock files actually working for daemon and are removed afterwards" 
=> {
    my $pidlockfile = "$?FILE.lock";
    daemonize
            "sleep 2",
            pid-file => $pidlockfile,
            stdout => "s.out",
            stderr => "s.err",
            :shell;
    sleep 0.5;  # pidfile isn't created immediately, wait a bit
    my Int $pid = pid-from-pidfile($pidlockfile);
    ok is-alive($pid), "Still alive";
    sleep 3;
    nok pg-alive($pid), "Dead";
    nok lockfile-valid($pidlockfile), "Lockfile should be removed";
};

done-testing;
