#!/usr/bin/env perl6
use Test::ClientServer;
use Test;

plan 1;

# This isn't listed in /etc/services so it should be safe.
my $port = 44444;

# do a simple network echo server, like S32-io/IO-Socket-INET.t does.
.run given Test::ClientServer.new(
    # :client is a sub that takes one argument, a callback that's supposed to
    # block until the server becomes ready.
    client => sub (&client-ready-callback) {
        diag('Client waiting for server');

        # Call this *before* connecting - it will block until the server is up.
        &client-ready-callback();

        diag('Client connecting');

        my $socket = IO::Socket::INET.new(
            :host('127.0.0.1'),
            :port($port),
        );

        diag('Connection established');

        my Str $sent = 'The quick brown fox jumped over the lazy dog';
        $socket.send($sent);
        my Str $received = $socket.recv();

        is($received, "Server says: $sent", 'echo test');

        return;
    },
    # :server is similar to :client, but it should call the callback to signal
    # that it's ready itself.
    server => sub (&server-ready-callback) {
        my $socket = IO::Socket::INET.new(
            :localhost('127.0.0.1'),
            :localport($port),
            :listen
        );

        # Call this *after* the server is ready.
        &server-ready-callback();

        my $client = $socket.accept();
        my $buf = $client.recv();
        $client.send("Server says: $buf");
        $client.close();

        return;
    },
    # :timeout is 30 seconds by default. If anything is still running by then
    # it's killed.
    :timeout(10),
);
