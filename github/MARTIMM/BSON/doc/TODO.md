# Bugs, known limitations and todo

### Todo

* Lack of other Perl 6 types support
* Change die() statements to use X::BSON exceptions to notify caller and place further responsability there. This is done for Document.pm6
* Perl 6 Int variables are integral numbers of arbitrary size. This means that any integer can be stored as large or small as you like. Int is encoded as described in version 0.8.4 (i.e. int32 or int64). When integers get larger or smaller then 64 bits can describe, then the Int should be encoded as a binary array of some type.
* Support for decimal 128 type = BSON type ID \x13.
* Tests some more exceptions of Binary
* Better checks for wrong sizes of buffers along every type encountered
* Modify timestamp (en/de)coding to be an object
* The exception objects are subject to change into a simpler class: one instead of several. This will become X::BSON.



### Bugs
