#!/usr/bin/env perl6
use Test::ClientServer;
use Test;

plan 2;

# Simulate a server taking too long to start
throws_like {
    .run given Test::ClientServer.new(
        :timeout(3),
        server => sub (&callback) { sleep(10); &callback(); },
        client => sub (&callback) { &callback(); },
    );
}, X::Test::ClientServer;

my $end = now - BEGIN now;

ok(3 < $end < 10, 'Timeout works sanely')
    or diag("Failure: 3 < $end < 10")
        and say 'Bail out! Not safe to run further tests without sane timeout behaviour.';
