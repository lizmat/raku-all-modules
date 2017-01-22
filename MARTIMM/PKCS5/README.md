# Public Key Cryptography Standards \#5 (PKCS 5)

[![Build Status](https://travis-ci.org/MARTIMM/PKCS5.svg?branch=master)](https://travis-ci.org/MARTIMM/PKCS5)
[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/MARTIMM/pkcs5?branch=master&passingText=Windows%20-%20OK&failingText=Windows%20-%20FAIL&pendingText=Windows%20-%20pending&svg=true)](https://ci.appveyor.com/project/MARTIMM/pkcs5/branch/master)
[![License](http://martimm.github.io/label/License-label.svg)](http://www.perlfoundation.org/artistic_license_2_0)

This package implements part of PKCS 5 which is, according to the [wikipedia](https://en.wikipedia.org/wiki/PKCS), a Password-based Encryption Standard. The derivation algorithm PBKDF2 is implemented as a class in this package.

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

See documentation at

* [PKCS5::PBKDF2](https://github.com/MARTIMM/PKCS5/blob/master/doc/PBKDF2.pdf)

* [Release notes](https://github.com/MARTIMM/PKCS5/blob/master/doc/CHANGES.md)

## Versions of PERL, MOARVM and MongoDB

This project is tested with latest Rakudo built on MoarVM implementing Perl v6.c.

## AUTHORS

```
Marcel Timmerman (MARTIMM on github)
```
## CONTACT

MARTIMM on github: PKCS5
