# Public Key Cryptography Standards \#5 (PKCS 5)

[![Build Status](https://travis-ci.org/MARTIMM/PKCS5.svg?branch=master)](https://travis-ci.org/MARTIMM/PKCS5)

This package implements part of PKCS 5 which is, according to the ![wiki](https://en.wikipedia.org/wiki/PKCS), a Password-based Encryption Standard. The derivation algorithm PBKDF2 is implemented as a class in this package.

## Synopsis

```
  use PKCS5::PBKDF2;

  my PKCS5::PBKDF2 $p .= new;

  $spw2 = $p.derive-hex(
    Buf.new('pencil'.encode),
    Buf.new( 65, 37, 194, 71, 228, 58, 177, 233, 60, 109, 255, 118),
    4096,
  );

  is $spw2, '1d96ee3a529b5a5f9e47c01f229a2cb8a6e15f7d', '4096 iteration hex';
```

## DOCUMENTATION

## INSTALLING THE MODULES

Use panda to install the package like so.
```
$ panda install PKCS5
```

## Versions of PERL, MOARVM and MongoDB

This project is tested with latest Rakudo built on MoarVM implementing Perl v6.c.

## BUGS, KNOWN LIMITATIONS AND TODO

## CHANGELOG

See [semantic versioning](http://semver.org/). Please note point 4. on
that page: *Major version zero (0.y.z) is for initial development. Anything may
change at any time. The public API should not be considered stable.*

* 0.1.4
  * Added tests from rfc6070
* 0.1.3
  * Changed terminology. PRF into CGH for cryptographic hash
* 0.1.1
  * Added pod doc.
* 0.1.0
  * Implemented derive() and derive-hex()
* 0.0.1 Setup

## LICENSE

Released under [Artistic License 2.0](http://www.perlfoundation.org/artistic_license_2_0).

## AUTHORS

```
Marcel Timmerman (MARTIMM on github)
```
## CONTACT

MARTIMM on github: PKCS5
