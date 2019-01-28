#! /usr/bin/env perl6
use v6.c;
use Net::NNG;

    my $url = "tcp://127.0.0.1:8887";

    my $pub = nng-pub0-open;
    nng-listen $pub, $url;

    my @clients = do for 1..8 -> $client-id {
        start {
            CATCH { warn "Error in client $_: { .gist }" }

            my $sub = nng-sub0-open;
            nng-dial $sub, $url;
            for 1..15 {
                nng-subscribe $sub, "/count";

                say "Client $client-id: ", nng-recv($sub).decode('utf8').substr(6)
            }
            nng-close $sub
        }
    }

    my $server = start {
        CATCH { warn "Error in server: { .gist }" }

        for 1..15 {
            nng-send $pub, "/count$_".encode('utf8');
            sleep 0.5;
        }
    }

    await Promise.allof: |@clients, $server;

    nng-close $pub
