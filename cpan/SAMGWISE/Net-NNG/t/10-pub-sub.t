#! /usr/bin/env perl6
use v6.c;
use Test;
use Net::NNG;

my $pub = nng-pub0-open;
my @subs = do for 1..8 { nng-sub0-open }

my $url = 'tcp://127.0.0.1:8886';
my $header = '/foo';
my $message = 'Subliminal';

# Start listening on server socket
nng-listen($pub, $url);

# Start up clients
my @clients = do for @subs {
    start {
        CATCH { warn "Error in client: { .gist }" }
        nng-dial($_, $url);
        ok nng-subscribe($_, $header).so, "Subscribed to publisher";
        nng-recv($_).decode('utf8')
    }
}

# Start server
my $server = start {
    CATCH { warn "Error in server: { .gist }" }
    diag 'Publishing';

    nng-send $pub, "$header$message".encode('utf8');
}

await Promise.allof: $server, |@clients;

for @clients {
    is .result, "$header$message", "Client returned pubished message"
}

# clean up
nng-close($_) for |@subs, $pub;

done-testing
