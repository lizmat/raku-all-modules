use experimental :pack;

use Test;
plan 1;

use Net::HTTP::POST;

subtest {
    my $url     = "http://httpbin.org/post";
    my $payload = "a=b&c=d&f=";
    my $body    = Buf.new($payload.ords);

    my $response = Net::HTTP::POST($url, :$body);
    is $response.status-code, 200, "200";

    my $results = from-json($response.body.unpack("A*"));
    is $results<data>, $payload;
}, "Basic POST";
