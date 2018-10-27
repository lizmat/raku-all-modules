use v6;
use Test;

plan 2;

use HTTP::Signature;
use HTTP::Request;

my $request-str = Q:b (POST /foo?param=value&pet=dog HTTP/1.1\r\nHost: example.com\r\nDate: Thu, 05 Jan 2012 21:31:40 GMT\r\nContent-Type: application/json\r\nContent-MD5: Sd/dVLAcvNLSq16eXua5uQ==\r\nContent-Length: 18\r\n\r\n{"hello": "world"}\r\n);
my $private-key = q (
-----BEGIN RSA PRIVATE KEY-----
MIICXgIBAAKBgQDCFENGw33yGihy92pDjZQhl0C36rPJj+CvfSC8+q28hxA161QF
NUd13wuCTUcq0Qd2qsBe/2hFyc2DCJJg0h1L78+6Z4UMR7EOcpfdUE9Hf3m/hs+F
UR45uBJeDK1HSFHD8bHKD6kv8FPGfJTotc+2xjJwoYi+1hqp1fIekaxsyQIDAQAB
AoGBAJR8ZkCUvx5kzv+utdl7T5MnordT1TvoXXJGXK7ZZ+UuvMNUCdN2QPc4sBiA
QWvLw1cSKt5DsKZ8UETpYPy8pPYnnDEz2dDYiaew9+xEpubyeW2oH4Zx71wqBtOK
kqwrXa/pzdpiucRRjk6vE6YY7EBBs/g7uanVpGibOVAEsqH1AkEA7DkjVH28WDUg
f1nqvfn2Kj6CT7nIcE3jGJsZZ7zlZmBmHFDONMLUrXR/Zm3pR5m0tCmBqa5RK95u
412jt1dPIwJBANJT3v8pnkth48bQo/fKel6uEYyboRtA5/uHuHkZ6FQF7OUkGogc
mSJluOdc5t6hI1VsLn0QZEjQZMEOWr+wKSMCQQCC4kXJEsHAve77oP6HtG/IiEn7
kpyUXRNvFsDE0czpJJBvL/aRFUJxuRK91jhjC68sA7NsKMGg5OXb5I5Jj36xAkEA
gIT7aFOYBFwGgQAQkWNKLvySgKbAZRTeLBacpHMuQdl1DfdntvAyqpAZ0lY0RKmW
G6aFKaqQfOXKCyWoUiVknQJAXrlgySFci/2ueKlIE1QqIiLSZ8V8OlpFLRnb1pzI
7U1yQXnTAEFYM560yJlzUpOb1V4cScGd365tiSMvxLOvTA==
-----END RSA PRIVATE KEY-----
);

#fFrom http://tools.ietf.org/html/draft-cavage-http-signatures-05
my $expected-authorization-header = 'Signature keyId="Test",algorithm="rsa-sha256", signature="ATp0r26dbMIxOopqw0OfABDT7CKMIoENumuruOtarj8n/97Q3htHFYpH8yOSQk3Z5zh8UxUym6FYTb5+A0Nz3NRsXJibnYi7brE/4tx5But9kkFGzG+xpUmimN4c3TMN7OFH//+r8hBf7BT9/GmHDUVZT2JzWGLZES2xDOUuMtA="';

my $signer = HTTP::Signature.new(
    keyid => 'Test',
    secret => $private-key,
    algorithm => 'rsa-sha256',
);

my $request = HTTP::Request.new;
$request.parse($request-str);

$request = $signer.sign-request( $request );

my $authorization-header = $request.header.field('Authorization').Str;

is $authorization-header, $expected-authorization-header, 'Default rsa-sha256, no header specified';

$request = HTTP::Request.new;
$request.parse($request-str);

$signer.headers = <(request-target) host date content-type content-md5 content-length>;

$request = $signer.sign-request( $request );

$expected-authorization-header = 'Signature keyId="Test",algorithm="rsa-sha256",headers="(request-target) host date content-type content-md5 content-length", signature="G8/Uh6BBDaqldRi3VfFfklHSFoq8CMt5NUZiepq0q66e+fS3Up3BmXn0NbUnr3L1WgAAZGplifRAJqp2LgeZ5gXNk6UX9zV3hw5BERLWscWXlwX/dvHQES27lGRCvyFv3djHP6Plfd5mhPWRkmjnvqeOOSS0lZJYFYHJz994s6w="';

is $request.header.field('Authorization').Str, $expected-authorization-header, "All headers specified";
