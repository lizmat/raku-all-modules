use Test;
plan 2;

use Net::HTTP::Dialer;
use Net::HTTP::URL;
use Net::HTTP::Request;


subtest {
    my $url     = Net::HTTP::URL.new("http://httpbin.org/ip");
    my $method  = 'GET';
    my %header  = :Host<httpbin.org>, :User-Agent("perl6-net-http");
    my $request = Net::HTTP::Request.new(:$url, :$method, :%header);
    my $socket  = Net::HTTP::Dialer.new.dial($request);

    ok $socket ~~ IO::Socket::INET, 'IO::Socket::INET';
}, 'IO::Socket::INET selected and works';


if Net::HTTP::Dialer.?can-ssl {
    subtest {
        my $url     = Net::HTTP::URL.new("https://httpbin.org/ip");
        my $method  = 'GET';
        my %header  = :Host<httpbin.org>, :User-Agent("perl6-net-http");
        my $request = Net::HTTP::Request.new(:$url, :$method, :%header);
        my $socket  = Net::HTTP::Dialer.new.dial($request);

        ok $socket ~~ IO::Socket::SSL, 'IO::Socket::SSL';
    }, 'IO::Socket::SSL selected and works';
}
else {
    ok 1, "Skip: Can't do SSL. Is IO::Socket::SSL available?";
}
