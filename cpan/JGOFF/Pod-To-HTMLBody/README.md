# Pod-To-HTMLBody [![Build Status](https://secure.travis-ci.org/drforr/perl6-Pod-To-HTMLBody.svg?branch=master)](http://travis-ci.org/drforr/perl6-Pod-To-HTMLBody)
Pod-To-HTMLBody
=======

Generates a HTML <body/> fragment

Please note that there's a Pod::To::Tree module that will get broken out once
it handles the test cases, and Pod::To::HTMLBody will use that instead of
surrounding the ::To::Tree module.

Installation
============

* Using zef (a module management tool bundled with Rakudo Star):

```
    zef update && zef install Pod::To::HTMLBody
```

## Testing

To run tests:

```
    prove -e perl6
```

## Author

Jeffrey Goff, DrForr on #perl6, https://github.com/drforr/

## License

Artistic License 2.0
