#! /usr/bin/env perl6
use v6.c;
use Test;
use Net::NNG;

my $surveyor = nng-surveyor0-open;
my @responders = do for 1..8 { nng-respondent0-open }

my $url = 'tcp://127.0.0.1:8868';
my $message = 'Sound out';

nng-listen($surveyor, $url);

my @clients = do for @responders.kv -> $n, $sock {
    start {
        CATCH { warn "Error in client: { .gist }" }
        nng-dial($sock, $url);
        return fail "($n) Error recieving survey" unless nng-recv($sock).decode('utf8') eq $message;
        nng-send $sock, "$n".encode('utf8')
    }
}

my $server = start {
    CATCH { warn "Error in server: { .gist }" }
    diag 'Surveying';

    nng-survey-duration $surveyor, 3000;
    nng-send $surveyor, $message.encode('utf8');

    my @responses = gather for 1..8 {
        given nng-recv($surveyor) {
            when .so { take .decode('utf8') }
            default { $*ERR.say: .gist; last }
        }
    }

    @responses
}


await Promise.allof: $server, |@clients;

ok @clients.map( *.result ).all.so, "Clients executed without error";
is-deeply $server.result.sort, (0..7).map( *.Str ), "All clients replied";

# clean up
nng-close($_) for |@responders, $surveyor;

done-testing
