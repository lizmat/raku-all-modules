### ASN::META

Experimental Perl 6 module that is able to compile [ASN.1](https://en.wikipedia.org/wiki/Abstract_Syntax_Notation_One) specification into set of Perl 6 types.

#### What ASN::META does not?

* It does not generate Perl 6 code (at least, textual form).
* The module knows nothing about ASN.1 encoding means, it purely generates Perl 6 types.
  For this purpose a separate module may be used. Currently, goal is to have full compatibility
  with [ASN::BER](https://github.com/Altai-man/ASN-BER) module.

#### What ASN::META does?

Main workflow is as follows:

* A specification file's path is passed to ASN::META on module `use`
* (internally, `ASN::Grammar` is used to parse the specification)
* ASN::META uses parsed specification to generate appropriate types with [MOP](https://docs.perl6.org/language/mop)
* Generated types for particular ASN.1 specification are precompiled and exported

#### What it does?

#### Synopsis

```perl6
# In file `schema.asn`:
WorldSchema

DEFINITIONS IMPLICIT TAGS ::= BEGIN
Rocket ::= SEQUENCE
{
   name      UTF8String,
   message   UTF8String DEFAULT "Hello World",
   fuel      ENUMERATED {
       solid(0),
       liquid(1),
       gas(2)
   },
   speed     CHOICE {
      mph    [0] INTEGER,
      kmph   [1] INTEGER
   }  OPTIONAL,
   payload   SEQUENCE OF UTF8String
}
END

# In file `User.pm6`:
use ASN::META <file schema.asn>;

# `Rocket` type is exported by ASN::META
my Rocket $rocket = Rocket.new(name => 'Rocker', :fuel(solid),
        speed => Speed.new((mph => 9001)),
        payload => Array[Str].new('A', 'B', 'C'));


# As well as inner types being promoted to top level:
say Fuel;  # generated enum
say solid; # value of this enum, (solid ~~ Fuel) == true
say Speed; # Generated type based on ASNChoice from ASN::BER
```
