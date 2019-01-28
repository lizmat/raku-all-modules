#! /usr/bin/env perl6
use v6.c;
use Bench;
use Net::NNG;

my $b = Bench.new;

my ($rep-sock, $req-sock) = (nng-rep0-open, nng-req0-open);

my $url = 'tcp://127.0.0.1:8887';

nng-listen $rep-sock, $url;
nng-dial $req-sock, $url;

my $server = start {
    CATCH { warn "Encountered error in server thread: { .gist }" }
    loop {
        my $message = nng-recv($rep-sock);
        nng-send $rep-sock, $message
    }
}

my $inet-server = start {
    my $listen = IO::Socket::INET.new( :listen,
        :localhost<localhost>,
        :localport(3333) );
    loop {
        my $conn = $listen.accept;
        try {
            while my $buf = $conn.recv(:bin) {
                $conn.write: $buf;
            }
        }
        $conn.close;

        CATCH {
            default { .payload.say }
        }

    }
}


for ('a', 'Benchmark this!', 'bcdefg' x 128, 'abcdefgh' x 1024, 'ijklmnop' x 8192).map( *.encode: 'utf8' ) -> $message {
    $b.cmpthese( 2000, {
        "nng-req-rep({ $message.elems })" => sub {
            nng-send $req-sock, $message;
            nng-recv $req-sock
        },
        "socket-inet({ $message.elems })" => sub {
            my $conn = IO::Socket::INET.new( :host<localhost>, :port(3333), :bin );
            $conn.write: $message;
            $conn.recv;
            $conn.close;
        }
    });
}

# Cleanup
($req-sock, $rep-sock)
    .map( *.&nng-close )
