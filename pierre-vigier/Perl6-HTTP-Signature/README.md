# Perl6-HTTP-Signature

[![Build Status](https://travis-ci.org/pierre-vigier/Perl6-HTTP-Signature.svg?branch=master)](https://travis-ci.org/pierre-vigier/Perl6-HTTP-Signature)

## SYNOPSIS

ALPHA
Implementation of http signature as defined in [IETFF draft version 3](http://tools.ietf.org/html/draft-cavage-http-signatures-03)

Heavily inspired from [Authen::HTTP::Signature](https://github.com/mrallen1/Authen-HTTP-Signature) on perl5

*To sign a request:*
```perl6
use HTTP::Signature;
use HTTP::UserAgent;
use HTTP::Request;

my $req = HTTP::Request.new(
    :GET('http://www.example.com/path')
);

my $signer = HTTP::Signature.new(
    keyid       => 'Test',
    secret      => 'MySuperSecretKey',
    algorithm   => 'hmac-sha256',
);
my $signed-request = $signer->sign-request( $req );
my $ua = HTTP::UserAgent.new;
my $response = $ua.request( $signed-request );
```

*To verify a request:*

```perl6
use HTTP::Signature;

my $signer = HTTP::Signature.new(
    secret      => 'MySuperSecretKey',
);
if $signer.verify-request( $req ) {
    ...
}
```
## DESCRIPTION
