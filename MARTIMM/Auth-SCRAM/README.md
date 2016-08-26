# Salted Challenge Response Authentication Mechanism (SCRAM)

[![Build Status](https://travis-ci.org/MARTIMM/PKCS5.svg?branch=master)](https://travis-ci.org/MARTIMM/Auth-SCRAM)

This package implements secure authentication mechanism.

## Synopsis

```
```

## DOCUMENTATION

## INSTALLING THE MODULES

Use panda to install the package like so.
```
$ panda install Auth-SCRAM
```

## Versions of PERL, MOARVM and MongoDB

This project is tested with latest Rakudo built on MoarVM implementing Perl v6.c.

## BUGS, KNOWN LIMITATIONS AND TODO

* Implement server side code
* Keep information when calculated. User requst boolean and username/password/authzid must be kept the same. This saves time.
* Channel binding and several other checks
* Normalization with rfc3454 rfc7564 (stringprep).  saslPrep rfc4013 rfc7613

## CHANGELOG

See [semantic versioning](http://semver.org/). Please note point 4. on
that page: *Major version zero (0.y.z) is for initial development. Anything may
change at any time. The public API should not be considered stable.*

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
