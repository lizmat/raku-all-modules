use v6;
use UNIX::Daemonize :ALL;
use Test;

subtest {
    my $pidlockfile = "$?FILE.lock";
    daemonize(<sleep 3>, :pid-file($pidlockfile));
    sleep 0.5;
    daemonize(«rm $pidlockfile», :pid-file($pidlockfile));  # This won't start
    sleep 0.5;
    ok lockfile-valid($pidlockfile);
    sleep 3;
    nok lockfile-valid($pidlockfile);
}, "Won't create second daemon";

done-testing;
