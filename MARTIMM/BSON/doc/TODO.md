# Bugs, known limitations and todo

### Todo

* Lack of other Perl 6 types support
* Change die() statements with exceptions to notify caller and place further responsability there. This is done for Document.pm6
* Perl 6 Int variables are integral numbers of arbitrary size. This means that any integer can be stored as large or small as you like. Int is coded as described in version 0.8.4. When integers get larger or smaller then 64bit can describe, then the Int should be coded as a binary array of some type.
* Support for decimal 128 type = BSON type ID \x13.
* Tests some more exceptions of Binary

### Bugs

* An array in a document which is modified later with push, pop or otherwise will not be properly encoded.
