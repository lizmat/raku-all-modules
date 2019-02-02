### ASN::Grammar

This module contains a grammar for parsing [ASN.1](https://en.wikipedia.org/wiki/Abstract_Syntax_Notation_One) specification files.

#### Warnings

* The module was initially started with need to parse LDAP specification, so parts of ASN.1 grammar specification were deliberately omitted. However, Pull Requests with additional rules or fixes will be gladly accepted.

#### Synopsis

```perl6
my $spec = q:to/SPECEND/;
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
   speed     CHOICE
   {
      mph    [0] INTEGER,
      kmph   [1] INTEGER
   }  OPTIONAL,
   payload   SEQUENCE OF UTF8String
}
END
SPECEND

use ASN::Grammar;

# ASN::Module represents ASN.1 module
my $module = parse-ASN($spec);
say $module.name; # WorldSchema
say $module.schema; # IMPLICIT

# TypeAssignment and ValueAssignment represent top-level ASN.1 custom definitions
my ASN::TypeAssignment $type = $module.types[0];

say $type.name; # Rocket
my ASN::RawType $rocket-type = $type.type;
say $rocket-type.type; # 'SEQUENCE'

# `.params` method returns a hash of various
# information about type, in this case,
# only `fields` key that returns descriptions
# of complex type (SEQUENCE) components is present
for $rocket-type.params<fields><> -> $field {
    say $field;
}
# Code above results in:
# Field `name` of type `UTF8String`, no parameters
# ASN::RawType.new(name => "name", type => "UTF8String", params => {})

# Field `message` of type `UTF8String`, defaults to `Hello World`
# ASN::RawType.new(name => "message", type => "UTF8String", params => {:default("\"Hello World\"")})

# Field `fuel` of type `ENUMERATED`,
# has options presented as hash by `defs`(definitions) key
# ASN::RawType.new(name => "fuel", type => "ENUMERATED", params => {:defs(${:gas(2), :liquid(1), :solid(0)})})

# Field `speed` of type `CHOICE`, has `optional` flag in params,
# has choices exposed as a mapping of a textual key into ASN::Tag class and integer value
# ASN::RawType.new(name => "speed", type => "CHOICE", params => {:choices(${:kmph((ASN::Tag.new(class => "CONTEXT-SPECIFIC", value => 1)) => "INTEGER"), :mph((ASN::Tag.new(class => "CONTEXT-SPECIFIC", value => 0)) => "INTEGER")}), :optional})

# Field `payload` of type `SEQUENCE OF` with `of` parameter that represents type of elements as ASN::RawType
# ASN::RawType.new(name => "payload", type => "SEQUENCE OF", params => {:of(ASN::RawType.new(name => "UTF8String", type => "UTF8String", params => {}))})

```

#### Room for improvement

* Value definition part of ASN.1
* Various spacing/newline variants
* Fixes