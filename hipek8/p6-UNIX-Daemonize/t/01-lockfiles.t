use v6;
use Test;
use UNIX::Daemonize :ALL;

subtest {
    my $pid-file = ".tmp.lock";
    ok lockfile-create($pid-file);
    ok $pid-file.IO.e;
    ok lockfile-valid($pid-file);
    dies-ok {lockfile-create($pid-file)};
    ok lockfile-valid($pid-file);
    ok lockfile-remove($pid-file);
    nok $pid-file.IO.e;
}, "Valid lockfile created, creating again throws";

done-testing;
