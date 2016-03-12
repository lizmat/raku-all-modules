# XML::Class

Role to Serialize/De-Serialize a Perl 6 class to/from XML

## Synopsis

```

use XML::Class;

class Foo does XML::Class[xml-element => 'foo'] {
    has Int $.version = 0;
    has Str $.zub is xml-element;
}

my $f = Foo.new(zub => "pow");

say $f.to-xml; # <?xml version="1.0"?><foo xmlns="http://example.com/" version="0"><zub>pow</zub></foo>


```


## Description

This provides a relatively easy way to instantiate a Perl 6 object from XML and create XML
that describes the Perl 6 class in a consistent manner.

It is somewhat inspired by the XmlSerialization class of the .Net framework, but there are
other antecedents.

Using a relatively static definition of the relation between a class and XML that represents
it means that XML can be consistently parsed and generated in a way that should always
remain valid to the original description.

This module aims to map between Perl 6 object attributes and XML by providing some default
behaviours and some attribute traits to alter that behaviour to model the XML.

By default scalar attributes whose value type can be expressed as an XML simple type (e.g.
strings, real numbers, boolean, datetimes) will be serialised as attribute values or (with
an ```xml-element``` trait,) as elements with simple content.  Positional attributes will
always be serialised as a sequence of elements (with an optional container specified by a
trait,) likewise associative attributes (though the use of these is discouraged as there is
no constraint on the names of the elements which are taken from the keys of the Hash.)
Perl 6 classes are expressed as XML complex types with the same serialisation as above.
Provision is also made for the serialisation and de-serialisation of other than the builtin
types to simple contemt (trivial examples might be Version objects for instance,) and for
the handling of data that might be unknown at definition time (such as the xsd:Any in 
SOAP head and body elements,) by the use of "namespace maps".

There are things that explicitly aren't catered for such as  "mixed content" (that is
where XML markup may be within text content as in XHTML for example,) but that shouldn't
be a problem for data storage or messaging applications for the most part.  

The full documentation is available as POD or as [Markdown](Documentation.md)

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

    panda install XML::Class

I haven't tried this with "zef" but I have no reason to think it
shouldn't work if you would rather use that.

Other install mechanisms may be become available in the future.

## Support

Although there are quite a few tests for this I'm sure they don't
cover all the possible cases. So if you find something that isn't
tested for and doesn't work quite as expected please let me know.


Suggestions/patches are welcomed via github at

   https://github.com/jonathanstowe/XML-Class

## Licence

Please see the LICENCE file in the distribution

(C) Jonathan Stowe 2016
