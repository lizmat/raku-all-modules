use v6;
use Test;

use HTTP::Parser;

my @cases =
    ["GET / HTTP/1.0\r\nUser-Agent: a b c\r\n\r\n", [
        37, {
            :PATH_INFO("/"),
            :QUERY_STRING(""),
            :REQUEST_METHOD("GET"),
            :SERVER_PROTOCOL("HTTP/1.0"),
            :REQUEST_URI</>,
            :HTTP_USER_AGENT('a b c'),
            :SCRIPT_NAME(''),
        }
    ]],
    ["GET / HTTP/1.0\r\n\r\n", [
        18, {
            :PATH_INFO("/"),
            :QUERY_STRING(""),
            :REQUEST_METHOD("GET"),
            :SERVER_PROTOCOL("HTTP/1.0"),
            :REQUEST_URI</>,
            :SCRIPT_NAME(''),
        }
    ]],
    ["GET / HTTP/1.0\r\n\r\nhello", [
        18, {
            :PATH_INFO("/"),
            :QUERY_STRING(""),
            :REQUEST_METHOD("GET"),
            :SERVER_PROTOCOL("HTTP/1.0"),
            :REQUEST_URI</>,
            :SCRIPT_NAME(''),
        }
    ]],
    ["\r\nGET / HTTP/1.0\r\n\r\n", [ # pre-header blank lines are allowed (RFC 2616 4.1)
        20, {
            :PATH_INFO("/"),
            :QUERY_STRING(""),
            :REQUEST_METHOD("GET"),
            :SERVER_PROTOCOL("HTTP/1.0"),
            :REQUEST_URI</>,
            :SCRIPT_NAME(''),
        }
    ]],
    ["GET /foo?bar=3 HTTP/1.1\r\n\r\n", [
        27, {
            :PATH_INFO("/foo"),
            :QUERY_STRING("bar=3"),
            :REQUEST_METHOD("GET"),
            :SERVER_PROTOCOL("HTTP/1.1"),
            :REQUEST_URI</foo?bar=3>,
            :SCRIPT_NAME(''),
        }
    ]],
    ["GET /foo%2A%2c?bar=3 HTTP/1.1\r\n\r\n", [
        33, {
            REQUEST_METHOD => 'GET',
            PATH_INFO => '/foo*,',
            QUERY_STRING => 'bar=3',
            SERVER_PROTOCOL => 'HTTP/1.1',
            :REQUEST_URI</foo%2A%2c?bar=3>,
            :SCRIPT_NAME(''),
        }
    ]],
    ["GET / HTTP/1.0\r\n", [
        -2, {}
    ]],
    ["GET / HTTP/1.0\r\nhogehoge\r\n\r\n", [
        -1, { {:PATH_INFO("/"), :QUERY_STRING(""), :REQUEST_METHOD("GET"), :REQUEST_URI("/"), :SCRIPT_NAME(""), :SERVER_PROTOCOL("HTTP/1.0")} }
    ]],
    ["GET / HTTP/1.1\r\ncontent-type: text/html\r\n\r\n", [
        43, {
            :CONTENT_TYPE("text/html"),
            :PATH_INFO("/"),
            :QUERY_STRING(""),
            :REQUEST_METHOD("GET"),
            :SERVER_PROTOCOL("HTTP/1.1"),
            :REQUEST_URI</>,
            :SCRIPT_NAME(''),
        }
    ]],
;

for @cases {
    my ($req, $expected) = @($_);
    subtest {
        my ($retval, $env) = parse-http-request($req.encode('ascii'));
        is $retval, $expected[0], 'header size';
        if $retval >= 0 {
            is-deeply $env, $expected[1];
        }
    }, $req.subst(/\r/, '\\r', :g).subst(/\n/, '\\n', :g);
    last;
}

done-testing;
