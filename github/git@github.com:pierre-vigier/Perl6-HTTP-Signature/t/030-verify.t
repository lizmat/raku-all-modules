use v6;
use Test;

plan 7;

use HTTP::Signature;
use HTTP::Request;

my $request-str = Q:b (POST /foo?param=value&pet=dog HTTP/1.1\r\nHost: example.com\r\nDate: Thu, 05 Jan 2012 21:31:40 GMT\r\nContent-Type: application/json\r\nContent-MD5: Sd/dVLAcvNLSq16eXua5uQ==\r\nContent-Length: 18\r\n\r\n{"hello": "world"});

my $authorization-header = 'Signature keyId="Test",algorithm="rsa-sha256", signature="ATp0r26dbMIxOopqw0OfABDT7CKMIoENumuruOtarj8n/97Q3htHFYpH8yOSQk3Z5zh8UxUym6FYTb5+A0Nz3NRsXJibnYi7brE/4tx5But9kkFGzG+xpUmimN4c3TMN7OFH//+r8hBf7BT9/GmHDUVZT2JzWGLZES2xDOUuMtA="';

my $public-key = q (
-----BEGIN RSA PUBLIC KEY-----
MIGJAoGBAMIUQ0bDffIaKHL3akONlCGXQLfqs8mP4K99ILz6rbyHEDXrVAU1R3Xf
C4JNRyrRB3aqwF7/aEXJzYMIkmDSHUvvz7pnhQxHsQ5yl91QT0d/eb+Gz4VRHjm4
El4MrUdIUcPxscoPqS/wU8Z8lOi1z7bGMnChiL7WGqnV8h6RrGzJAgMBAAE=
-----END RSA PUBLIC KEY-----
);

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

my $signer_rsa = HTTP::Signature.new(
    keyid => 'Keyid',
    secret => $private-key,
    algorithm => 'rsa-sha256',
);

#fFrom http://tools.ietf.org/html/draft-cavage-http-signatures-05
my $verify_rsa = HTTP::Signature.new(
    secret => $public-key,
);

my $request = HTTP::Request.new;
$request.parse($request-str);
$request.header.field( Authorization => $authorization-header );

is $verify_rsa.verify-request( $request ), True, "Verification ok";

$request = HTTP::Request.new;
$request.parse($request-str);
my $to-verify = $signer_rsa.sign-request( $request );
is $verify_rsa.verify-request( $to-verify ), True, "rsa-sha256 verification OK";

$signer_rsa.algorithm = 'rsa-sha1';
$verify_rsa.algorithm = 'rsa-sha1';
$to-verify = $signer_rsa.sign-request( $request );
is $verify_rsa.verify-request( $to-verify ), True, "rsa-sha1 verification OK";

$signer_rsa.algorithm = 'rsa-md5';
$verify_rsa.algorithm = 'rsa-md5';
$to-verify = $signer_rsa.sign-request( $request );
is $verify_rsa.verify-request( $to-verify ), True, "rsa-md5 verification OK";

my $secret = "This should be secret";
my $signer_hmac = HTTP::Signature.new(
    keyid => 'Keyid',
    secret => $secret,
    algorithm => 'hmac-sha256',
);

my $verify_hmac = HTTP::Signature.new(
    secret => $secret
);

$request = HTTP::Request.new;
$request.parse($request-str);
$to-verify = $signer_hmac.sign-request( $request );
is $verify_hmac.verify-request( $to-verify ), True, "hmac-sha256 verification OK";

$signer_hmac.algorithm = 'hmac-sha1';
$request = HTTP::Request.new;
$request.parse($request-str);
$to-verify = $signer_hmac.sign-request( $request );
is $verify_hmac.verify-request( $to-verify ), True, "hmac-sha1 verification OK";

$signer_hmac.algorithm = 'hmac-md5';
$request = HTTP::Request.new;
$request.parse($request-str);
$to-verify = $signer_hmac.sign-request( $request );
is $verify_hmac.verify-request( $to-verify ), True, "hmac-md5 verification OK";

