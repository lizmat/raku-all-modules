#!/usr/bin/env perl6
use Test::ClientServer;
use Test;

plan 2;

.run given Test::ClientServer.new(
    server => sub (&callback) { &callback(); pass('server code reached'); },
    client => sub (&callback) { &callback() },
    :timeout(10),
);

.run given Test::ClientServer.new(
    server => sub (&callback) { &callback() },
    client => sub (&callback) { &callback(); pass('client code reached'); },
    :timeout(10),
);
