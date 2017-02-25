See [semantic versioning](http://semver.org/). Please note point 4. on
that page: *Major version zero (0.y.z) is for initial development. Anything may
change at any time. The public API should not be considered stable*.

* 0.9.32
  * Removed Positional role from BSON::Document. This means no $d[$i] anymore. There was no use for it. Less code, less parsing and less object building time.
* 0.9.31
  * Added some tests in Document to check for proper pair data.
* 0.9.30
  * Moved and renamed an exception class from ObjectId.pm6 to a new module BSON.pm6 as X::BSON::Parse-objectid.
  * Also exception classes from Document are moved to BSON
  * Old bug removed which was only visible once in a long while. It had to do with promises which were most of the time kept but sometimes the thread was still busy. The code forgot to reprocess the planned threads.
* 0.9.29
  * Appveyor Tests
  * separated text from readme into several other documents.
* 0.9.28
  * Bug fix concat Buf arrays. Changes caused by changes in perl 6
* 0.9.27
  * Perl6 bug fixed, workarounds removed
* 0.9.25.1
  * Need to reprogram parts in Document caused by bugs/changes in perl6.
* 0.9.25
  * Speedup in encoding/decoding double using NativeCall. Tests are also done with int64 numbers but these do not improve when implemented natively. See the benchmark docs and code.
* 0.9.24
  * Cleanup modules and META
  * Small bugfix in Document.perl()
* 0.9.23
  * Added method find-key(Int -> Str). We had find-key(Str -> Int) already.
* 0.9.22
  * bugfix in perl showing Buf data
* 0.9.21
  * Beautify perl() output and added perl() methods to Binary, Javascript, Regex and ObjectId.
  * Cutting out old stuff now that Document is matured and MongoDB does not rely on the old stuff anymore. Their accompanying test programs are removed too.
  * Documentation for the other modules
  * Factored out Buf encoding. Must be done via BSON::Binary
  * Refactored encode/decode from Document to Binary and ObjectId
* 0.9.20
  * Bugfix. When a entry is overwritten, the promise used for it to encode the entry was only deleted. It needs to be read first otherwise a thread is kept hanging around.
  * Bugfix. Promise needs to be tested for definiteness before await and delete
* 0.9.19
  * Modified taking sections of buf using subbuf
  * perl method modified showing structure of document
* 0.9.18
  * Bugfixes in Double decoding
* 0.9.17
  * Bugfixes in BSON::Document
  * Changes caused by perl6 6.c. Z operator changes and datetime usage
  * Ideas about parallel computing entries revised. Now only non-subdocuments are calculated in parallel. Subducuments are calculated when encode() is called.
* 0.9.16
  * Move around things
  * Some subs exported
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
  * Factoring out Exception classes from BSON and EDC-Tools into
    BSON/Exception.pm6
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

    ```
    multi method _string ( Str $s ) {...}
    multi method _string ( Array $a ) {...}
    ```

    into

    ```
    method _enc_string ( Str $s ) {...}
    method _dec_string ( Array $a ) {...}
    ```

    It also symplifies the dispatcher table.

* 0.5.1 Sending of double number to server with lower precision.
* 0.5.0 Added Buf to binary
* 0.4.0 Added processing of double number coming from server. Sending not yet possible.
* 0.2 .. 0.3 Something happened no doubt ;-).
* 0.1 basic Proof-of-concept working on Rakudo 2011.07.
