use v6;
use Test;

use HTTP::Parser;

my @cases =
    ["GET / HTTP/1.0\x[0d]\x[0a]User-Agent: a b c\x[0d]\x[0a]\x[0d]\x[0a]", [
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
    ["GET / HTTP/1.0\x[0d]\x[0a]\x[0d]\x[0a]", [
        18, {
            :PATH_INFO("/"),
            :QUERY_STRING(""),
            :REQUEST_METHOD("GET"),
            :SERVER_PROTOCOL("HTTP/1.0"),
            :REQUEST_URI</>,
            :SCRIPT_NAME(''),
        }
    ]],
    ["GET / HTTP/1.0\x[0d]\x[0a]\x[0d]\x[0a]hello", [
        18, {
            :PATH_INFO("/"),
            :QUERY_STRING(""),
            :REQUEST_METHOD("GET"),
            :SERVER_PROTOCOL("HTTP/1.0"),
            :REQUEST_URI</>,
            :SCRIPT_NAME(''),
        }
    ]],
    ["\x[0d]\x[0a]GET / HTTP/1.0\x[0d]\x[0a]\x[0d]\x[0a]", [ # pre-header blank lines are allowed (RFC 2616 4.1)
        20, {
            :PATH_INFO("/"),
            :QUERY_STRING(""),
            :REQUEST_METHOD("GET"),
            :SERVER_PROTOCOL("HTTP/1.0"),
            :REQUEST_URI</>,
            :SCRIPT_NAME(''),
        }
    ]],
    ["GET /foo?bar=3 HTTP/1.1\x[0d]\x[0a]\x[0d]\x[0a]", [
        27, {
            :PATH_INFO("/foo"),
            :QUERY_STRING("bar=3"),
            :REQUEST_METHOD("GET"),
            :SERVER_PROTOCOL("HTTP/1.1"),
            :REQUEST_URI</foo?bar=3>,
            :SCRIPT_NAME(''),
        }
    ]],
    ["GET /foo%2A%2c?bar=3 HTTP/1.1\x[0d]\x[0a]\x[0d]\x[0a]", [
        33, {
            REQUEST_METHOD => 'GET',
            PATH_INFO => '/foo*,',
            QUERY_STRING => 'bar=3',
            SERVER_PROTOCOL => 'HTTP/1.1',
            :REQUEST_URI</foo%2A%2c?bar=3>,
            :SCRIPT_NAME(''),
        }
    ]],
    ["GET / HTTP/1.0\x[0d]\x[0a]", [
        -2, {}
    ]],
    ["GET / HTTP/1.0\x[0d]\x[0a]hogehoge\x[0d]\x[0a]\x[0d]\x[0a]", [
        -1, { {:PATH_INFO("/"), :QUERY_STRING(""), :REQUEST_METHOD("GET"), :REQUEST_URI("/"), :SCRIPT_NAME(""), :SERVER_PROTOCOL("HTTP/1.0")} }
    ]],
    ["GET / HTTP/1.1\x[0d]\x[0a]content-type: text/html\x[0d]\x[0a]\x[0d]\x[0a]", [
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
}

done-testing;
