# BSON support

![Face](http://modules.perl6.org/logos/BSON.png)

Implements [BSON specification](http://bsonspec.org/).

## INSTALLING BSON

Use panda to install the package like so. When installing MongoDB, BSON will be
installed automatically as a dependency.


```
$ panda install MongoDB
```

## VERSION PERL AND MOARVM

```
$ perl6 -v
This is perl6 version 2015.01-77-gd320f00 built on MoarVM version 2015.01-21-g4ee4925
```

## SYNOPSIS

    my $b = BSON.new;

    my Buf $encoded = $b.encode( {
        "_id" => BSON::ObjectId.new( "4e4987edfed4c16f8a56ed1d" ),
        "some string"   => "foo",
        "some number"   => 123,
        "some array"    => [ ],
        "some hash"     => { },
        "some bool"     => Bool::True,
      }
    );

    my $decoded = $b.decode( $encoded );


### SUPPORTED TYPES

        Perl6           <=> BSON
    
    [x] Str             <=> UTF-8 string
    [x] Int             <=> 32-bit Integer
    [x] Bool            <=> Boolean "true" / "false"
    [x] Buf             <=> Generic binary subtype
    [x] Array           <=> Array
    [x] Hash            <=> Embedded document
    [x] BSON::ObjectId  <=> ObjectId

    [x] Num             <=> 64-bit Double. This is kind of emulated and
                            therefore slower. It suffices to say that this will
                            be implemented differently later.
    [ ] FatRat
    [ ] Rat
    [ ] int64
    [ ] UUID
    [ ] MD5
    [x] DateTime        <=> int64 UTC datetime, seconds since January 1st 1970
    [x] BSON::Regex     <=> Regular expression serverside searches
    [x] BSON::Javascript<=> Javascript code transport with or whithout scope

        And quite a few more perl6 types. Now binary types are possible it
        might be an idea to put the perl6 specific types into binary. There
        are 127 user definable types there, so place enough.


### EXTENDED TYPES

```BSON::ObjectId``` - Internal representation is 12 bytes,
but to keep it consistent with MongoDB presentation described in
[ObjectId spec](http://dochub.mongodb.org/core/objectids)
constructor accepts string containing 12 hex pairs:

    BSON::ObjectId.new( '4e4987edfed4c16f8a56ed1d' )

Internal ```Buf``` can be reached by `.Buf` accessor.
Method ```.perl``` is available for easy debug.

## BUGS, KNOWN LIMITATIONS AND TODO

* Big integers (int64). Perl 6 Int variables are integral numbers of arbitrary
  size. This means that any integer can be stored as large or small as you like.
  This also means that BSON or another package must introduce an Int32 and Int64
  class while the standard type Int can be coded as a binary array.
* Num is implemented but kind off emulated which makes it slower. However it was
  necessary to implement it because much information from the MongoDB server is
  send back as a double like count() and list_databases(). Num needs test for
  NaN.
* Lack of other Perl 6 types support, this is directly related to not yet
  specified pack/unpack in Perl6.
* Change die() statements in return with exception to notify caller and place
  further responsability there.
* Tests needs to be extended to test larger documents. The failure in version
  0.5.4 could then be prevented.

## CHANGELOG

See [semantic versioning](http://semver.org/). Please note point 4. on
that page: *Major version zero (0.y.z) is for initial development. Anything may
change at any time. The public API should not be considered stable*.

* 0.8.3 - Bugfix test on empty javascript objects
* 0.8.2 - Bugfix Javascript type wrong size for javascript and scope 
* 0.8.1 - Bugfix Javascripting
* 0.8.0 - Added BSON::Javascript with or without scope
* 0.7.0 - Added BSON::Regex type
* 0.6.0 - Added DateTime type.
* 0.5.5 - Big problems. Bugs fixed.
* 0.5.4 - Double numbers better precision calculations
* 0.5.3 - Double numbers -Inf and -0 are not processed correctly.
* 0.5.2 - Change method names to have a better readability. E.g.

          ####multi method _string ( Str $s ) {...}
          ####multi method _string ( Array $a ) {...}

          into

          ####method _enc_string ( Str $s ) {...}
          ####method _dec_string ( Array $a ) {...}

          It also symplifies the dispatcher table.
* 0.5.1 - Sending of double number to server with lower precision.
* 0.5.0 - Added Buf to binary
* 0.4.0 - Added processing of double number coming from server. Sending not
          yet possible.
* 0.2 .. 0.3 Something happened no doubt ;-).
* 0.1 - basic Proof-of-concept working on Rakudo 2011.07.

##LICENSE

Released under [Artistic License 2.0](http://www.perlfoundation.org/artistic_license_2_0).

## AUTHOR

Original creator of the modules is Pawel Pabian (2011-2015, v0.3)(bbkr on github)
Current maintainer Marcel Timmerman (2015-present)

## CONTACT

MARTIMM on github

