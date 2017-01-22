# Salted Challenge Response Authentication Mechanism (SCRAM)

[![Build Status](https://travis-ci.org/MARTIMM/Auth-SCRAM.svg?branch=master)](https://travis-ci.org/MARTIMM/Auth-SCRAM)
[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/MARTIMM/auth-scram?branch=master&passingText=Windows%20-%20OK&failingText=Windows%20-%20FAIL&pendingText=Windows%20-%20pending&svg=true)](https://ci.appveyor.com/project/MARTIMM/auth-scram/branch/master)
[![License](http://martimm.github.io/label/License-label.svg)](http://www.perlfoundation.org/artistic_license_2_0)

This package implements secure authentication mechanism.

## Synopsis

```
# Example from rfc (C = client, s = server)
# C: n,,n=user,r=fyko+d2lbbFgONRv9qkxdawL
# S: r=fyko+d2lbbFgONRv9qkxdawL3rfcNHYJY1ZVvWVs7j,s=QSXCR+Q6sek8bf92,i=4096
# C: c=biws,r=fyko+d2lbbFgONRv9qkxdawL3rfcNHYJY1ZVvWVs7j,
#    p=v0X8v3Bz2T0CJGbJQyF0X+HI4Ts=
# S: v=rmF9pqV8S7suAoZWja4dJRkFsKQ=
#
class MyClient {

  # Send client first message to server and return server response
  method client-first ( Str:D $client-first-message --> Str ) {

    # Send $client-first-message to server;

    # Get server response, this is the server first message
    'r=fyko+d2lbbFgONRv9qkxdawL3rfcNHYJY1ZVvWVs7j,s=QSXCR+Q6sek8bf92,i=4096';
  }

  # Send client final message to server and return server response
  method client-final ( Str:D $client-final-message --> Str ) {

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

$sc.c-nonce-size = 24;
$sc.c-nonce = 'fyko+d2lbbFgONRv9qkxdawL';

my $error = $sc.start-scram;
```

## Documentation

* [SCRAM](https://github.com/MARTIMM/Auth-SCRAM/blob/master/doc/SCRAM.pdf)
* [SCRAM::Client](https://github.com/MARTIMM/Auth-SCRAM/blob/master/doc/Client.pdf)
* [SCRAM::Server](https://github.com/MARTIMM/Auth-SCRAM/blob/master/doc/Server.pdf)

Change log
* [Release notes](https://github.com/MARTIMM/Auth-SCRAM/blob/master/doc/CHANGES.md)

Bugs, todo and known limitations
* [Bugs, todo](https://github.com/MARTIMM/Auth-SCRAM/blob/master/doc/TODO.md)

## Installing

Use panda to install the package like so.
```
$ panda install Auth-SCRAM
```
or
```
$ zef install Auth-SCRAM
```

## Versions of PERL, MOARVM

This project is tested with latest Rakudo built on MoarVM implementing Perl v6.c.

## Authors

```
Marcel Timmerman (MARTIMM on github)
```
