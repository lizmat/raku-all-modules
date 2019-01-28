#! /usr/bin/env perl6
use v6.c;
use Test;
use Net::NNG;
use Net::NNG::Options;

my ($req, $rep) = (nng-req0-open, nng-rep0-open);

ok nng-setopt($req, NNG_OPT_RECVTIMEO, 1000, :ms), "Set receive timeout limit";

my $url = 'tcp://127.0.0.1:8883';

ok nng-dial($req, $url) ~~ Failure, "Failure when dailing before listner is ready";

nng-listen($rep, $url);

ok nng-dial($req, $url), "Dial when listener is ready";

ok nng-send($req, 'request-1'.encode), "Send to server which isn't currently receiving";

# Loop this to make it easy to prevent requests blocking forever
start loop {
    # first reply OK
    is nng-recv($rep).decode, 'request-1', "Recieve message already in buffer";
    nng-send $rep, 'reply-1'.encode;
    # Second reply
    is nng-recv($rep).decode, 'request-2', "Recieve message 2";
    nng-send $rep, 'reply-2'.encode;
    # Second reply time out
    is nng-recv($rep).decode, 'request-3', "Receive message 3";
    sleep 3; # Sleep past our time out
    nng-send $rep, 'reply-3'.encode;
}

is nng-recv($req).decode, 'reply-1', 'Reply from buffered request';

ok nng-send($req, 'request-2'.encode), "Send message to Rep server";
is nng-recv($req).decode, 'reply-2', "Receive reply 2 from Rep server";

ok nng-send($req, 'request-3'.encode), "Send request 3 to Rep server";
ok nng-recv($req) ~~ Failure, "Time out waiting for reply 3 from server";

# clean up
nng-close($_) for $req, $rep;

done-testing
