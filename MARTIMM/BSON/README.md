# BSON support

![Face](http://modules.perl6.org/logos/BSON.png)

Implements [BSON specification](http://bsonspec.org/).

## VERSION PERL AND MOARVM

```
$ perl6 -v
This is perl6 version 2015.01-5-g912a7fa built on MoarVM version 2015.01-5-ga29eaa9
```

Documentation can be found in doc/Original-README.md and lib/MongoDB.pod.

## INSTALL

Use panda to install the package like so. BSON will be installed as a
dependency.


```
$ panda install MongoDB
```

## SYNOPSIS

    my $b = BSON.new;
    my Buf $encoded = $b.encode(
        {
            "_id" => BSON::ObjectId.new( "4e4987edfed4c16f8a56ed1d" ),
            "some string"   => "foo",
            "some number"   => 123,
            "some array"    => [ ],
            "some hash"     => { },
            "some bool"     => Bool::True,
        }
    );
    my $decoded = $b.decode( $encoded );


### NATIVE TYPES

        Perl6           <=> BSON
    
    [x] Str             <=> UTF-8 string
    [x] Int             <=> 32-bit Integer
    [x] Bool            <=> Boolean "true" / "false"
    [x] Buf             <=> Generic binary subtype
    [x] Array           <=> Array
    [x] Hash            <=> Embedded document
    [x] BSON::ObjectId  <=> ObjectId

    [x] Num             <=> 64-bit Double. *When sending a Num to the server
                            some precision is lost*. Also this is kind of
                            emulated and therefore slower. It suffices to say
                            that this will be implemented differently later.
    [ ] FatRat
    [ ] Rat
    [ ] Real
    [ ] int64

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

## BUGS

## CHANGELOG

* 0.5.1 - Sending of double number to server with lower precision.
* 0.5.0 - Added Buf to binary
* 0.4.0 - Added processing of double number coming from server. Sending not
          yet possible.
* 0.2 .. 0.3 Something happened no doubt ;-).
* 0.1 - basic Proof-of-concept working on Rakudo 2011.07.

##LICENSE

Released under [Artistic License 2.0](http://www.perlfoundation.org/artistic_license_2_0).

## AUTHOR

Original creator of the modules is Pawel Pabian (2011-2015)(bbkr on github)
Current maintainer Marcel Timmerman (2015-present)

## CONTACT

MARTIMM on github

