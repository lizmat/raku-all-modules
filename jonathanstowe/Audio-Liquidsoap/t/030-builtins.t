#!perl6

use v6;

use Test;
plan 6;

use Audio::Liquidsoap;
use Test::Util::ServerPort;

my $port = get-unused-port();
use lib 't/lib';

use RunServer;

my $data-dir = $*PROGRAM.parent.child('data');
my $play-dir = $data-dir.child('play');

my $script = $data-dir.child('test-resources.liq');

if try RunServer.new(port => $port) -> $ls {

    diag "Testing on port $port";
    $ls.stderr.tap(-> $v { diag $v });
    $ls.run;

    diag "waiting until server settles ...";
    sleep 2;

    if $ls.Promise.status ~~ Kept {
        skip-rest "failed to start server";
    }
    else {
        pass "Started the server";
        my $soap;
        lives-ok { $soap = Audio::Liquidsoap.new(port => $port) }, "get client";

        my $v;
        lives-ok { $v = $soap.version }, "get version";
        isa-ok $v, Version, "and it's a version";
        my $d;
        lives-ok { $d = $soap.uptime }, "uptime";
        isa-ok $d, Duration, "and we got a duration";
        diag "Testing with Liquidsoap version $v started at " ~ DateTime.new(now - $d);


        LEAVE {
            $ls.kill;
            await $ls.Promise;
        }
    }
}
else {
    skip-rest "can't start test liquidsoap";
}

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
