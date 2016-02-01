# JSON::Infer

Create Perl6 classes to represent JSON data by some dodgy inference.

## Synopsis

Use the script to do it simply:

```
# Create the module in the directory "foo"

p6-json-infer --uri=http://api.mixcloud.com/spartacus/party-time/ --out-dir=foo --class-name=Mixcloud::Show

```

Or do it in your own code:

```

use JSON::Infer;

my $obj = JSON::Infer.new()
my $ret = $obj.infer(uri => 'http://api.mixcloud.com/spartacus/party-time/', class-name => 'Mixcloud::Show');

say $ret.make-class; # Print the class definition

```

## Description

JSON is nearly ubiquitous on the internet, developers love it for making
APIs.  However the webservices that use it for transfer of data rarely
have a machine readable specification that can be turned into code so
developers who want to consume these services usually have to make the
client definition themselves.

This module aims to provide a way to generate Perl 6 classes that can represent
the data from a JSON source.  The structure and the types of the data is
inferred from a single data item so the accuracy may depend on the
consistency of the data.

## Installation

Assuming you have a working perl6 installation you should be able to
install this with *ufo* :

    ufo
    make test
    make install

*ufo* can be installed with *panda* for rakudo:

    panda install ufo

Or you can install directly with "panda":

    # From the source directory
   
    panda install .

    # Remote installation

    panda install JSON::Infer

Other install mechanisms may be become available in the future.

## Support


Suggestions/patches are welcomed via github at

   https://github.com/jonathanstowe/JSON-Infer

## Licence

Please see the LICENCE file in the distribution

(C) Jonathan Stowe 2015, 2016
