use v6;
use Test;
use IO::Socket::SSL;

plan 2;

my $ssl = IO::Socket::SSL.new(:host<github.com>, :port(443));
isa-ok $ssl, IO::Socket::SSL, 'new 1/1';
$ssl.close;

subtest {
    lives-ok { $ssl = IO::Socket::SSL.new(:host<google.com>, :port(443)) };
    is $ssl.print("GET / HTTP/1.1\r\nHost:www.google.com\r\nConnection:close\r\n\r\n"), 57;
    ok $ssl.get ~~ /\s3\d\d\s/|/\s2\d\d\s/;
    $ssl.close;
}, 'google: ssl';

