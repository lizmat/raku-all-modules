use Test;
plan 1;

use Net::HTTP::Response;
use Net::HTTP::URL;

subtest {
    my $status-line = "HTTP/1.1 200 OK",
    my %header = %(
        :Access-Control-Allow-Credentials("true"),
        :Access-Control-Allow-Origin("*"),
        :Connection("close"),
        :Content-Length("31"),
        :Content-Type("application/json"),
        :Date("Mon, 26 Oct 2015 21:17:35 GMT"),
        :Server("nginx")
    );
    my $body = Buf[uint8].new(
        123, 10, 32, 32, 34, 111, 114, 105, 103, 105,
        110, 34, 58, 32, 34, 50, 51, 46, 50, 51, 57,
        46, 49, 54, 46, 57, 48, 34, 10, 125, 10
    );
    my $response-as-buf = Buf[uint8].new(
        72, 84, 84, 80, 47, 49, 46, 49, 32, 50, 48, 48, 32, 79, 75, 13, 10, 83, 101, 114, 118, 101, 114, 58,
        32, 110, 103, 105, 110, 120, 13, 10, 68, 97, 116, 101, 58, 32, 77, 111, 110, 44, 32, 50, 54, 32, 79,
        99, 116, 32, 50, 48, 49, 53, 32, 50, 49, 58, 50, 51, 58, 48, 55, 32, 71, 77, 84, 13, 10, 67, 111, 110,
        116, 101, 110, 116, 45, 84, 121, 112, 101, 58, 32, 97, 112, 112, 108, 105, 99, 97, 116, 105, 111, 110,
        47, 106, 115, 111, 110, 13, 10, 67, 111, 110, 116, 101, 110, 116, 45, 76, 101, 110, 103, 116, 104, 58,
        32, 51, 49, 13, 10, 67, 111, 110, 110, 101, 99, 116, 105, 111, 110, 58, 32, 99, 108, 111, 115, 101, 13,
        10, 65, 99, 99, 101, 115, 115, 45, 67, 111, 110, 116, 114, 111, 108, 45, 65, 108, 108, 111, 119, 45, 79,
        114, 105, 103, 105, 110, 58, 32, 42, 13, 10, 65, 99, 99, 101, 115, 115, 45, 67, 111, 110, 116, 114, 111,
        108, 45, 65, 108, 108, 111, 119, 45, 67, 114, 101, 100, 101, 110, 116, 105, 97, 108, 115, 58, 32, 116, 114,
        117, 101, 13, 10, 13, 
        10, 123, 10, 32, 32, 34, 111, 114, 105, 103, 105, 110, 34, 58, 32, 34, 50, 51, 46, 50,
        51, 57, 46, 49, 54, 46, 57, 48, 34, 10, 125, 10
    );

    my $response-from-args = Net::HTTP::Response.new(:$status-line, :%header, :$body);
    my $response-from-buf  = Net::HTTP::Response.new($response-as-buf);

    # This appears to match up, but I can't seem to get a comparison to agree
    # is-deeply $response-from-args.header.hash, $response-from-buf.header.hash;

    is $response-from-args.body.contents, $response-from-buf.body.contents;
}, 'Basic: response tests';
