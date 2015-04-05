use v6;
use Test;
use IO::Socket::SSL;

plan 3;

my $ssl = IO::Socket::SSL.new(:host<github.com>, :port(443));
isa_ok $ssl, IO::Socket::SSL, 'new 1/1';
$ssl.close;

subtest {
    lives_ok { $ssl = IO::Socket::SSL.new(:host<google.com>, :port(443)) };
    is $ssl.send("GET / HTTP/1.1\r\nHost:www.google.com\r\nConnection:close\r\n\r\n"), 57;
    ok $ssl.get ~~ /\s3\d\d\s/|/\s2\d\d\s/;
    $ssl.close;
}, 'google: ssl';


skip "Negotiate ssl degrade", 1;
subtest {
    return;
    lives_ok { $ssl = IO::Socket::SSL.new(:host<google.com>, :port(80)) };
    is $ssl.send("GET / HTTP/1.1\r\nHost:www.google.com\r\nConnection:close\r\n\r\n"), 57;
    ok $ssl.get ~~ /\s200\s/;
}, "Connect non-ssl port:80";
