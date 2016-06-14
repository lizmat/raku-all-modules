use Test;
plan 1;

use Net::HTTP::POST;

sub from-json($text) is export {
    INIT my $INTERNAL_JSON = (so try { ::("Rakudo::Internals::JSON") !~~ Failure }) == True;
    $INTERNAL_JSON
        ?? ::("Rakudo::Internals::JSON").from-json($text)
        !! do {
            my $a = ::("JSONPrettyActions").new();
            my $o = ::("JSONPrettyGrammar").parse($text, :actions($a));
            JSONException.new(:$text).throw unless $o;
            $o.ast;
        }
}

subtest {
    my $url     = "http://httpbin.org/post";
    my $payload = "a=b&c=d&f=";
    my $body    = Buf.new($payload.ords);

    my $response = Net::HTTP::POST($url, :$body);
    is $response.status-code, 200, "200";

    my $results = from-json($response.content(:force));
    is $results<data>, $payload;
}, "Basic POST";
