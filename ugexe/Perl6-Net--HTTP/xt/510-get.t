use Test;
plan 3;

use Net::HTTP::GET;

subtest {
    my $url = "http://httpbin.org";

    my $response200 = Net::HTTP::GET($url ~ '/status/200');
    is $response200.status-code, 200;

    my $response400 = Net::HTTP::GET($url ~ '/status/400');
    is $response400.status-code, "400";
}, "Basic";

subtest {
    my $url = "http://httpbin.org/redirect/3";
    my $response = Net::HTTP::GET($url);
    is $response.status-code, 200, 'Status code of final redirect is 200';

    my $rel-url = "http://httpbin.org/relative-redirect/2";
    my $rel-response = Net::HTTP::GET($rel-url);
    is $rel-response.status-code, 200, 'Status code of final relative redirect is 200';

    my $abs-url = "http://httpbin.org/absolute-redirect/1";
    my $abs-response = Net::HTTP::GET($abs-url);
    is $abs-response.status-code, 200, 'Status code of final absolute redirect is 200';
}, "Redirect";


if Net::HTTP::Dialer.?can-ssl {
    subtest {
        my $https2https-url = "https://httpbin.org/absolute-redirect/2";
        my $https2https-response = Net::HTTP::GET($https2https-url);
        is $https2https-response.status-code, 200, 'Status code of final redirect is 200';

        my $http2https-url = "http://github.com";
        my $http2https-response = Net::HTTP::GET($http2https-url);
        is $http2https-response.status-code, 200, 'Status code of final redirect is 200';
    }, 'Redirect with SSL';
}
else {
    ok 1, "Skip: Can't do SSL. Is IO::Socket::SSL available?";
}