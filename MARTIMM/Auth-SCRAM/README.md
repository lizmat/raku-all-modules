# Salted Challenge Response Authentication Mechanism (SCRAM)

[![Build Status](https://travis-ci.org/MARTIMM/PKCS5.svg?branch=master)](https://travis-ci.org/MARTIMM/Auth-SCRAM)

This package implements secure authentication mechanism.

## Synopsis

```
# Example from rfc
# C: n,,n=user,r=fyko+d2lbbFgONRv9qkxdawL
# S: r=fyko+d2lbbFgONRv9qkxdawL3rfcNHYJY1ZVvWVs7j,s=QSXCR+Q6sek8bf92,i=4096
# C: c=biws,r=fyko+d2lbbFgONRv9qkxdawL3rfcNHYJY1ZVvWVs7j,
#    p=v0X8v3Bz2T0CJGbJQyF0X+HI4Ts=
# S: v=rmF9pqV8S7suAoZWja4dJRkFsKQ=
#
class MyClient {

  # Send client first message to server and return server response
  method message1 ( Str:D $client-first-message --> Str ) {

    # Send $client-first-message to server;

    # Server response is server first message
    'r=fyko+d2lbbFgONRv9qkxdawL3rfcNHYJY1ZVvWVs7j,s=QSXCR+Q6sek8bf92,i=4096';
  }

  # Send client final message to server and return server response
  method message2 ( Str:D $client-final-message --> Str ) {

    # Send $client-final-message to server.

    # Server response is server final message
    'v=rmF9pqV8S7suAoZWja4dJRkFsKQ=';
  }

  method error ( Str:D $message --> Str ) {
    # Errors? nah ... (Famous last words!)
  }
}

  my Auth::SCRAM $sc .= new(
    :username<user>,
    :password<pencil>,
    :client-side(MyClient.new),
  );
  isa-ok $sc, Auth::SCRAM;

  $sc.c-nonce-size = 24;
  $sc.c-nonce = 'fyko+d2lbbFgONRv9qkxdawL';

  my $error = $sc.start-scram;
```

## DOCUMENTATION

See pod documentation

## INSTALLING THE MODULES

Use panda to install the package like so.
```
$ panda install Auth-SCRAM
```

## Versions of PERL, MOARVM

This project is tested with latest Rakudo built on MoarVM implementing Perl v6.c.

## BUGS, KNOWN LIMITATIONS AND TODO

* Keep information when calculated. User request boolean and username/password/authzid must be kept the same. This saves time.
* Channel binding and several other checks
* Normalization with rfc3454 rfc7564 (stringprep).  saslPrep rfc4013 rfc7613

## CHANGELOG

See [semantic versioning](http://semver.org/). Please note point 4. on
that page: *Major version zero (0.y.z) is for initial development. Anything may
change at any time. The public API should not be considered stable.*

* 0.3.2
  * Refactoring code to have hidden methods. In current setup it was not possible. This failed because of role usage, so keep it the same.
  * documentation.
* 0.3.1
  * Bugfixes
  * Some server errors can be detected and returned
* 0.3.0
  * Server side code implemented. Lack error return if there are any.
* 0.2.0
  * Refactored code into server and client parts. User interface is unchanged.
* 0.1.1
  * renamed clean-up() optional method into cleanup().
* 0.1.0
  * mangle-password and clean-up in user objects are made optional. Called when defined.
* 0.0.2
  * Add server verification
* 0.0.1 Setup

## LICENSE

Released under [Artistic License 2.0](http://www.perlfoundation.org/artistic_license_2_0).

## AUTHORS

```
Marcel Timmerman (MARTIMM on github)
```
## CONTACT

MARTIMM on github: PKCS5
