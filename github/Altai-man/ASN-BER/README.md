### ASN::BER

This module is designed to allow one make Perl 6 types support encoding and decoding based on ASN.1-driven Basic Encoding Rules.

#### Warnings

* This is a beta release. Number of universal types is not even described and papercuts are possible.
* Main driving power beneath this is a desire to avoid writing every LDAP type
parsing and serializing code by hands. As a result, while some means to have more generic support
of ASN.1 are being prepared, contributing code to support greater variety of ASN.1 definitions
being expressed and handled correctly is appreciated.

#### Synopsis

```perl6
#`[
World-Schema DEFINITIONS IMPLICIT TAGS ::=
BEGIN
  Rocket ::= SEQUENCE
  {
     name      UTF8String (SIZE(1..16)),
     message   UTF8String DEFAULT "Hello World",
     fuel      ENUMERATED {solid, liquid, gas},
     speed     CHOICE
     {
        mph    [0] INTEGER,
        kmph   [1] INTEGER
     }  OPTIONAL,
     payload   SEQUENCE OF UTF8String
  }
END
]

# Necessary imports
use ASN::Types;
use ASN::Serializer;
use ASN::Parser;

# ENUMERATED is expressed as enum
enum Fuel <Solid Liquid Gas>;

# Mark CHOICE type as ASNChoice
class SpeedChoice does ASNChoice {
    method ASN-choice() {
        # Description of choice names, tags, types
        { mph => (1 => Int), kmph => (0 => Int) }
    }
}

# Mark our SEQUENCE as ASNSequence
class Rocket does ASNType {
    has Str $.name is UTF8String; # UTF8String
    has Str $.message is default-value("Hello World") is UTF8String; # DEFAULT
    has Fuel $.fuel; # ENUMERATED
    has SpeedChoice $.speed is optional; # CHOICE + OPTIONAL
    has Str @.payload is UTF8String; # SEQUENCE OF UTF8String

    # `ASN-order` method is a single _necessary_ method
    # which describes an order of attributes of type (here - SEQUENCE) to be encoded/decoded
    method ASN-order() {
        <$!name $!message $!fuel $!speed @!payload>
    }
}

my $rocket = Rocket.new(
        name => 'Falcon',
        fuel => Solid,
        speed => SpeedChoice.new((mph => 18000)),
        payload => ["Car", "GPS"]
);

say ASN::Serializer.serialize($rocket, :mode(Implicit)); # for now only IMPLICIT tag schema is supported and flag is not really used
# `ASN::Serializer.serialize($rocket, :debug)` - `debug` named argument enables printing of basic debugging messages

# Result: Blob.new(
#            0x30, 0x1B, # Outermost SEQUENCE
#            0x0C, 0x06, 0x46, 0x61, 0x6C, 0x63, 0x6F, 0x6E, # NAME, MESSAGE is missing
#            0x0A, 0x01, 0x00, # ENUMERATED
#            0x81, 0x02, 0x46, 0x50, # CHOICE
#            0x30, 0x0A, # SEQUENCE OF UTF8String
#                0x0C, 0x03, 0x43, 0x61, 0x72,  # UTF8String
#                0x0C, 0x03, 0x47, 0x50, 0x53); # UTF8String

# Will return an instance of Rocket class parsed from `$rocket-encoding-result` Buf
say ASN::Parser.new(:type(Rocket)).parse($rocket-encoding-result, :mode(Implicit));
```

#### ASN.1 "traits" handling rules

**This part is a design draft that might be changed in case if any issue that hinders development of LDAP will de discovered**

The main concept is to avoid unnecessary creation of new types that just serve as envelopes for
actual data and avoid boilerplate related to using such intermediate types. Hence, when possible,
we try to use native types and traits.

#### Tagging schema

For now, encoding is done as if `DEFINITIONS IMPLICIT TAGS` is applied for an outermost ASN.1 unit (i.e. "module").
Setting of other schemes is expected to be able to work via named argument passed to `serialize`|`parse` methods, yet this is not yet implemented.

#### Mapping from ASN.1 type to ASN::BER format

Definitions of ASN.1 types are made by use of:

* Universal types (`MessageID ::= INTEGER`)

Universal types are mostly handled with Perl 6 native types, currently implemented are:

| ASN.1 type      | Perl 6 type                    |
|-----------------|--------------------------------|
| BOOLEAN         | Bool                           |
| INTEGER         | Int                            |
| NULL            | ASN-Null                       |
| OCTET STRING    | Str                            |
| UTF8String      | Str                            |
| ENUMERATED      | enum                           |
| SEQUENCE        | class implementing ASNSequence |
| SEQUENCE OF Foo | Foo @.sequence                 |
| SET OF Foo      | ASNSetOf\[Foo\]                |
| CHOICE          | ASNChioce                      |

* User defined types (`LDAPDN ::= LDAPString`)

If it is based on ASN.1 type, just use this underlying one; So:

```
LDAPString ::= OCTET STRING
LDAPDN ::= LDAPString
```

results in

```perl6
has Str $.ldapdn is OctetString; # Ignore level of indirectness in type
```

One can inherit a class from `ASN::BER`'s types to make structure more strict if needed.

* SEQUENCE elements (`LDAPMessage ::= SEQUENCE {...}`)

Such elements are implemented as classes with `ASNSequence` role applied and `ASN-order` method implemented.
They are handled correctly if nested, so `a ::= SEQUENCE { ..., b SEQUENCE {...} }` will translate `a` and include
`b` as it's part, serializing the inner class instance.

* SEQUENCE OF elements

Array sigil may be used `has Foo @.foos`. In future, possibly more generic way of writing will be provided.

* SET elements (`Foo ::= SET {}`)

Not yet implemented, though typed `SET OF` can be done with:

```perl6
has ASNSetOf[Int] $.values;
submethod BUILD(Set :$values) { self.bless(values => ASNSetOf[Int].new($values)) }
```

* CHOICE elements

CHOICE elements are implemented by `ASNChoice` role applying.
For same types tagging must be used to avoid ambiguity, it is usually done using context-specific tags.

```
A ::= SEQUENCE {
    ...,
    authentication AuthenticationChoice
}

AuthenticationChoice ::= CHOICE {
  simple  [0] OCTET STRING,
            -- 1 and 2 reserved
  sasl    [3] SaslCredentials } -- SaslCredentials begin with LDAPString, which is a OCTET STRING
```

becomes

```
class AuthChoice is ASNChoice {
    # This example depicts a CHOICE with context-specific tags being provided
    # For cases where tag has an APPLICATION class, see example below
    # We are returning a Hash which holds a description of the CHOICE structure,
    # (name => (tag => type))
    method ASN-choice {
        { simple => (0 => ASN::Types::OctetString),
          sasl   => (3 => Cro::LDAP::Authentication::SaslCredentials) }
    }
}

class A {
    ...
    has AuthChoice $.authentication;
}

A.new(..., authentication => (simple => "466F6F"));
```

`simple` is a key for the internal pair, which consists of a tag to use and a CHOICE option type.

Another option, when there is no ambiguity, are usages of

* Universal type - are handled using appropriate universal types for a choice value.

* User-defined type with `APPLICATION`-wide tag.

If ASN.1 has APPLICATION-wide tag declared, for example:

```
BindRequest ::= [APPLICATION 0] SEQUENCE {
    ...
}
```

it might be expressed implementing `ASN-tag-value`:

```
class BindRequest does ASNSequence {
    method ASN-order {...}
    method ASN-tag-value { 0 } # [APPLICATION 0]
}
```

In this case, when such type is used as a part of a CHOICE, internal pair of CHOICE values is replaced with just a type:

```
class ProtocolChoice does ASNChoice {
    method ASN-choice {
        { bindRequest => Cro::LDAP::Request::Bind,
          ...
        }
    }
}

class Request does ASNSequence {
    ...
    has ProtocolChoice $.protocol-op;
}
```

`ASN-tag-value` method will be called and its result will be used as an APPLICATION class tag during encoding/decoding process.

#### ASN.1 type traits

##### Optional

Apply `is optional` trait to an attribute.

##### Default

Apply `is default-value` trait to an attribute. It additionally sets `is default` trait with the same value.
