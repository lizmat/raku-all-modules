[![Build Status](https://travis-ci.org/jamesalbert/JSON-WebToken.svg?branch=master)](https://travis-ci.org/jamesalbert/JSON-WebToken)

NAME
====

JSON::WebToken - JSON Web Token (JWT) implementation for Perl6

INSTALL
=======

    panda update
    panda install JSON::WebToken


SYNOPSIS
========

    use Data::Dump;
    use JSON::WebToken;
    use Test;

    my $claims = {
      iss => 'joe',
      exp => 1300819380
    };
    my $secret = 'secret';

    my $jwt = encode_jwt $claims, $secret; #, 'RS256';
    say "encoded " ~ Dump($claims) ~ " to $jwt";
    my $decoded = decode_jwt $jwt, $secret;
    say "decoded to " ~ Dump($decoded);

    is-deeply $decoded, $claims;
    done-testing;

DESCRIPTION
===========

WARNING: This module is brand-spankin' new. It only supports one type of encryption/decryption (HS256). Contributors Welcome!

JSON::WebToken is a JSON Web Token (JWT) implementation for Perl6

**THIS MODULE IS ALPHA LEVEL INTERFACE. **

METHODS
=======

encode($claims [, $secret, $algorithm, $extra_headers ]) : String
-----------------------------------------------------------------

The default and currently only supported encryption algorithm is `HS256 ` and the synopsis above explains how to do it. Once we support RSA, you will be able to specify the algorithm by doing:

    use JSON::WebToken;

    my $pricate_key_string = '...';
    my $public_key_string  = '...';
    my $claims = {
      iss => 'joe',
      exp => 1300819380
    };
    my $jwt = encode-jwt($claims, $pricate_key_string, 'RS256'); # NOTE: not supported yet

    my $decoded = decode-jwt $jwt, $public_key_string;

If and when you use RS256, RS384 or RS512 algorithm, [Crypt::OpenSSL::RSA ](Crypt::OpenSSL::RSA ) is required.

If you want to create a `Plaintext JWT `, should be specify `none ` for the algorithm.

    my $jwt = encode-jwt($claims, '', 'none');

decode($jwt [, $secret, $verify_signature, $accepted_algorithms ]) : HASH
-------------------------------------------------------------------------

This method decodes a hash from JWT string.

    my $decoded = decode-jwt $jwt, $secret, 1, ['HS256'];

Any signing algorithm (except "none") is acceptable by default, so you should check it with $accepted_algorithms parameter.

add_signing_algorithm($algorithm, $class)
-----------------------------------------

This method adds a signing algorithm.

    use JSON::WebToken;

    class Foo {
      method sign ($algorithm, $message, $key) {
        return 'H*'; # or whatever the heck your signature is
      }

      method verify ($algorithm, $message, $key, $signature) {
        $signature eq self.sign($algorithm, $message, $key);
      }
    }

    add_signing_algorithm Foo.new;

SEE ALSO [JSON::WebToken::Crypt::HMAC ](JSON::WebToken::Crypt::HMAC ) or [JSON::WebToken::Crypt::RSA ](JSON::WebToken::Crypt::RSA ).

FUNCTIONS
=========

encode_jwt($claims [, $secret, $algorithm, $extra_headers ]) : String
---------------------------------------------------------------------

Same as `encode() ` method.

decode_jwt($jwt [, $secret, $verify_signature, $accepted_algorithms ]) : Hash
-----------------------------------------------------------------------------

Same as `decode() ` method.

ERROR CODES
===========

JSON::WebToken::Exception will be thrown with following code.

ERROR_JWT_INVALID_PARAMETER
---------------------------

When some method arguments are not valid.

ERROR_JWT_MISSING_SECRET
------------------------

When secret is required. (`alg != "none" `)

ERROR_JWT_INVALID_SEGMENT_COUNT
-------------------------------

When JWT segment count is not between 2 and 4.

ERROR_JWT_INVALID_SEGMENT_ENCODING
----------------------------------

When each JWT segment is not encoded by base64url.

ERROR_JWT_UNWANTED_SIGNATURE
----------------------------

When `alg == "none" ` but signature segment found.

ERROR_JWT_INVALID_SIGNATURE
---------------------------

When JWT signature is invalid.

ERROR_JWT_NOT_SUPPORTED_SIGNING_ALGORITHM
-----------------------------------------

When given signing algorithm is not supported.

ERROR_JWT_UNACCEPTABLE_ALGORITHM
--------------------------------

When given signing algorithm is not included in acceptable_algorithms.

AUTHOR
======

jamesalbert AKA jimmyjam5000ME (Millennium Edition) <lt>jalbert1@uci.edu<gt>

Authors of Perl5 JSON::WebToken:

xaicron <lt>xaicron@cpan.orggt

zentooo

COPYRIGHT
=========

Copyright 2016 - jamesalbert

LICENSE
=======

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

SEE ALSO
========

[http://tools.ietf.org/html/draft-ietf-oauth-json-web-token ](http://tools.ietf.org/html/draft-ietf-oauth-json-web-token )
