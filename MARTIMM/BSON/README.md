# BSON support

![Face](logotype/logo_32x32.png) [![Build Status](https://travis-ci.org/MARTIMM/BSON.svg?branch=master)](https://travis-ci.org/MARTIMM/BSON)

Implements [BSON specification](http://bsonspec.org/).

## INSTALLING BSON

Use panda to install the package like so.
```
$ panda install BSON
```

When installing MongoDB, BSON will be installed automatically as a dependency.


## VERSION PERL AND MOARVM

* Perl6 version ```2015.11-143-g7046681```
* MoarVM version ```2015.11-19-g623eadf```


## SYNOPSIS

The first example code is the original method of serializing data into a BSON
structure. When used to save it lokally it is fine. However, because hashes are
involved the structure cannot be used to communicate with a mongodb server. The
hashes in perl6 do not keep the order as you will enter your data into the
structure and the mongodb server needs the data in some order. E.g. when using
commands, the command needs to be on the first key-value pair. Tricky
manipulations must be performed to keep the input order such as using arrays of
Pair.

Because of this a BSON::Document class has been developed (see second
example). This structure will keep the order and because of that there is no
need for cumbersome operations. At the moment it is much slower than the hashed
variant even with the encoding happening in the background and parallel.


```
use BSON;
my $b = BSON::Bson.new;

my Buf $encoded = $b.encode( {
    "_id" => BSON::ObjectId.new("4e4987edfed4c16f8a56ed1d"),
    "some string"   => "foo",
    "some number"   => 123,
    "some array"    => [ ],
    "some hash"     => { },
    "some bool"     => True,
  }
);

my $decoded = $b.decode($encoded);
```

Using the BSON::Document

```
use BSON::Document;

my BSON::Javascript $js .= new(:javascript('function(x){return x;}'));
my BSON::Javascript $js-scope .= new(
  :javascript('function(x){return x;}'),
  :scope(BSON::Document.new: (nn => 10, a1 => 2))
);

my BSON::Binary $bin .= new(:data(Buf,new(... some binary data ...));
my BSON::Regex $rex .= new( :regex('abc|def'), :options<is>);

my BSON::Document $d .= new: ( 'a number' => 10, 'some text' => 'bla die bla');
$d<oid> = BSON::ObjectId.new;
$d<javascript> = $js;
$d<js-scope> = $js-scope;
$d<datetime> = DateTime.now;
$d<bin> = $bin;
$d<rex> = $rex;
$d<null> = Any;
$d<array> = [ 10, 'abc', 345];
$d<subdoc1> = a1 => 10, bb => 11;
$d<subdoc1><b1> = q => 255;

my Buf $enc-doc = $d.encode;

my BSON::Document $new-doc .= new;
$new-doc.decode($enc-doc);

```

See also BSON/Document.pod


## BUGS, KNOWN LIMITATIONS AND TODO

* Num is implemented but kind off emulated which makes it slower. However it was
  necessary to implement it because much information from the MongoDB server is
  send back as a double like count() and in info returned by list_databases().
* Lack of other Perl 6 types support, this is directly related to not yet
  specified pack/unpack in Perl6.
* Change die() statements in return with exception to notify caller and place
  further responsability there. This is done for Document.pm6
* Perl 6 Int variables are integral numbers of arbitrary size. This means that
  any integer can be stored as large or small as you like. Int can be coded as
  described in version 0.8.4 and when larger or smaller then maybe it is
  possible the Int can be coded as a binary array of some type.


## CHANGELOG

See [semantic versioning](http://semver.org/). Please note point 4. on
that page: *Major version zero (0.y.z) is for initial development. Anything may
change at any time. The public API should not be considered stable*.

* 0.9.16
  * move around things
  * some subs exported
* 0.9.15
  * ```@*INC``` is gone, ```use lib``` is the way. A lot of changes done by
    zoffixznet.
* 0.9.14
  * All dies are now throwing excpetions X::Parse-document or X::NYS in
    BSON::Document.
  * More tests are added.
* 0.9.13
  * Document with encoding and decoding running in parallel. Much slower than
    direct hashes but keeps input order.
* 0.9.12
  * Num needs test for NaN.
* 0.9.11
  * Factored out code from BSON::Bson to BSON::Double.
  * Deprecate underscore methods modified in favor of dashed ones:
      BSON::Bson, BSON::Double, BSON::Binary, BSON::EDCTools
  * Changed API of Double and Javascript
* 0.9.10
  * Change module filenames
  * quick fix using multi methods/subs caused by new version of perl6. Its now
    more logical while before automtic coercion took place it must modified
    explicitly now. Later proper types must be used like byte arrays to handle
    Buf's or maybe read from the Buf directly. Saves a translation step.

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

