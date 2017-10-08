use v6;
use UNIX::Daemonize :ALL;
use Test;

subtest {
    my $pidlockfile = "$?FILE.lock";
    daemonize(<sleep 2>, :pid-file($pidlockfile), :repeat);
    # file isn't created immediately, wait a bit
    sleep 0.5;
    my Int $pid = pid-from-pidfile($pidlockfile);
    ok is-alive($pid), "Daemon still alive";
    sleep 3;
    ok is-alive($pid), "Daemon is restarted";
    
    terminate-process-group-from-file($pidlockfile);
    sleep 0.5;
    nok pg-alive($pid), "Now dead";
    nok $pidlockfile.IO.e;
}, "Repeat parameter works";

done-testing;
