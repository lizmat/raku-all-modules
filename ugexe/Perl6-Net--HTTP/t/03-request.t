use Test;
plan 1;

use Net::HTTP::Request;
use Net::HTTP::URL;

subtest {
    my $want-str = q{GET /search?x=1 HTTP/1.1}
        ~ "\r\n" ~ q{Host: google.com}
        ~ "\r\n" ~ q{User-Agent: perl6-net-http}
        ~ "\r\n\r\n";

    my $url     = Net::HTTP::URL.new("http://google.com/search?x=1");
    my $method  = 'GET';
    my %header  = :Host<google.com>, :User-Agent("perl6-net-http");

    my $request = Net::HTTP::Request.new(:$url, :$method, :%header);
    ok $request.Str eq $want-str;

    subtest {
        temp %header;
        %header<Host>:delete if %header<Host>:exists;
        my $request = Net::HTTP::Request.new(:$url, :$method, :%header);

        is $request.Str, $want-str;
    }, 'Auto setting the host header';
}, 'Basic: request header tests';
