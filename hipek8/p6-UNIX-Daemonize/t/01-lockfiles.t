use v6;
use Test;
use UNIX::Daemonize :ALL;

subtest {
    my $pid-file = "$?FILE.lock";
    ok lockfile-create($pid-file);
    ok $pid-file.IO.f;
    ok lockfile-valid($pid-file), "Created valid lockfile";
    dies-ok { lockfile-create($pid-file) };
    ok lockfile-valid($pid-file), "Lockfile still valid";
    ok lockfile-remove($pid-file);
    nok $pid-file.IO.f;
}, "Valid lockfile created, creating again throws";

done-testing;
