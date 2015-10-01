# BSON support

![Face](http://modules.perl6.org/logos/BSON.png)

Implements [BSON specification](http://bsonspec.org/).

## INSTALLING BSON

Use panda to install the package like so.
```
$ panda install BSON
```

When installing MongoDB, BSON will be installed automatically as a dependency.


## VERSION PERL AND MOARVM

* Perl6 version ```2015.09-162-gdd6c855```
* MoarVM version ```2015.09-39-g1434283```

## SYNOPSIS

    my $b = BSON::Bson.new;

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
    [x] Int              => 32-bit Integer if -2147483646 < n < 2147483647
                         => 64-bit Integer if -9,22337203685e+18 < n < 9,22337203685e+18
                            Fails if larger/smaller with X::BSON::ImProperUse
    [x] Int             <=  32/64 bit integers.
    [x] Bool            <=> Boolean "true" / "false"
    [x] BSON::Binary    <=> All kinds of binary data
    [x]                     0x00 Generic type
    [ ]                     0x01 Function
    [-]                     0x02 Binary old, deprecated
    [-]                     0x03 UUID old, deprecated
    [x]                     0x04 UUID
    [x]                     0x05 MD5
    [x] Array           <=> Array
    [x] Hash            <=> Embedded document
    [x] BSON::ObjectId  <=> ObjectId

    [x] Num             <=> 64-bit Double. This is kind of emulated and
                            therefore slower. It suffices to say that this will
                            be implemented differently later.
    [ ] FatRat
    [ ] Rat
    [x] DateTime        <=> int64 UTC datetime, seconds since January 1st 1970
    [x] BSON::Regex     <=> Regular expression for serverside searches
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

* Num is implemented but kind off emulated which makes it slower. However it was
  necessary to implement it because much information from the MongoDB server is
  send back as a double like count() and in info returned by list_databases().
* Num needs test for NaN.
* Lack of other Perl 6 types support, this is directly related to not yet
  specified pack/unpack in Perl6.
* Change die() statements in return with exception to notify caller and place
  further responsability there.
* Perl 6 Int variables are integral numbers of arbitrary size. This means that
  any integer can be stored as large or small as you like. Int can be coded as
  described in version 0.8.4 and when larger or smaller then maybe it is
  possible the Int can be coded as a binary array of some type.


## CHANGELOG

See [semantic versioning](http://semver.org/). Please note point 4. on
that page: *Major version zero (0.y.z) is for initial development. Anything may
change at any time. The public API should not be considered stable*.

* 0.9.9
  * Changes because of updates in perl6
* 0.9.8
  * Tests for binary data UUID and MD5
* 0.9.7
  * Factoring out Exception classes from BSON and EDC-Tools into BSON/Exception.pm6
  * Bugfix in META.info
  * Parse errors throw exceptions.
* 0.9.6
  * Factoring out methods from BSON into EDC-Tools.
  * Methods in EDC-Tools converted into exported subs.
* 0.9.5
  * Changed caused by rakudo update.
  * Hashes work like hashes... mongodb run_command needs command on first key
    value pair. Because of this a few multi methods are added to process Pair
    arrays instead of hashes.
* 0.9.4
  * Tests from 0.9.3 has shown that using an index in arrays is faster than
    shifting the bytes out one by one. This is now modified in BSON.pm6.
* 0.9.3
  * Bugfix encoding very small double precision floating point numbers.
  * Working to encapsulate the encoding/decoding work. When also the method used
    to walk through the byte array using shift() when decoding and instead use
    an index in the string, it might well be possible to parallelize the
    encoding as well as decoding process. Also keeping an index is also faster
    than shifting because the array doesn't have to be changed all the time.
  * Changed role/class idea of test files Double.pm6 and Encodable.pm6. These
    are now D.pm6, EDC.pm6 and EDC-Tools.pm6. The Double is there a role while
    the Encodable is a class.
  * Tests needs to be extended to test larger documents. The failure in version
    0.5.4 could then be prevented. Test 703-encodable.t to test encoding objects
    has a document with subdocuments and several doubles.
  * EDC.pm6, D.pm6 and EDC-Tools.pm6 has replaced array shifts with array
    indexing when decoding which is slightly faster.
  * EDC.pm6 has first preparations to introduce concurrency using cas() when
    decoding to update document result atomically.
  * Tests have shown that scheduled code is too short to run parallel compared
    to the bookkeeping around it. So keep the original code but replace the
    array shifts with indexing when decoding.
* 0.9.2 Upgraded Rakudo * ===> Bugfix in BSON
* 0.9.1 Testing with decode/encode classes and roles
* 0.9.0
  * Created BSON::Binary and removed the Buf type. In this way the
    Class can be used for all kinds of binary type such as images, UUID,
    MD5, code, etcetera.
  * Created X::BSON::NYS to throw ```Not Yet Supported``` messages.

* 0.8.4
  * Modification of Int translation.
    Tests have shown that incrementing a 32bit integer can change into
    64bit integers. 

    So, to keep minimal number of bytes to represent an integer Int should
    be translated to int32 when -2147483646 < n < 2147483647 and it should
    be translated to int64 when -9,22337203685e+18 < n < 9,22337203685e+18
    and should fail when otherwise.

  * With these changes also some bugs are removed involving negative
    numbers and int64 numbers are now handled.

  * Created X::BSON::ImProperUse to throw ```Improperly Used Type``` messages.

  * Created X::BSON::Deprecated to throw ```BSON Deprecated type``` messages.

* 0.8.3 Bugfix test on empty javascript objects
* 0.8.2 Bugfix Javascript type wrong size for javascript and scope 
* 0.8.1 Bugfix Javascripting
* 0.8.0 Added BSON::Javascript with or without scope
* 0.7.0 Added BSON::Regex type
* 0.6.0 Added DateTime type.
* 0.5.5 Big problems. Bugs fixed.
* 0.5.4 Double numbers better precision calculations
* 0.5.3 Double numbers -Inf and -0 are not processed correctly.
* 0.5.2
  * Change method names to have a better readability. E.g.

    ####multi method _string ( Str $s ) {...}
    ####multi method _string ( Array $a ) {...}

    into

    ####method _enc_string ( Str $s ) {...}
    ####method _dec_string ( Array $a ) {...}

    It also symplifies the dispatcher table.

* 0.5.1 Sending of double number to server with lower precision.
* 0.5.0 Added Buf to binary
* 0.4.0 Added processing of double number coming from server. Sending not
         yet possible.
* 0.2 .. 0.3 Something happened no doubt ;-).
* 0.1 basic Proof-of-concept working on Rakudo 2011.07.

## LICENSE

Released under [Artistic License 2.0](http://www.perlfoundation.org/artistic_license_2_0).

## AUTHOR

Original creator of the modules is Pawel Pabian (2011-2015, v0.3)(bbkr on github)
Current maintainer Marcel Timmerman (2015-present)

## CONTACT

MARTIMM on github

