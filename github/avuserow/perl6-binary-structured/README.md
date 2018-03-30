NAME
====

Binary::Structured - read and write binary formats defined by classes

SYNOPSIS
========

    use Binary::Structured;

    # Binary format definition
    class PascalString is Binary::Structured {
	    has uint8 $!length is written(method {$!string.bytes});
	    has Buf $.string is read(method {self.pull($!length)}) is rw;
    }

    # Reading
    my $parser = PascalString.new;
    $parser.parse(Buf.new("\x05hello world".ords));
    say $parser.string.decode("ascii"); # "hello"

    # Writing
    $parser.string = Buf.new("some new data".ords);
    say $parser.build; # Buf:0x<0d 73 6f 6d 65 20 6e 65 77 20 64 61 74 61>

DESCRIPTION
===========

Binary::Structured provides a way to define classes which know how to parse and emit binary data based on the class attributes. The goal of this module is to provide building blocks to describe an entire file (or well-defined section of a file), which can easily be parsed, edited, and rebuilt.

This module was inspired by the Python library `construct`, with the class-based representation inspired by Perl 6's `NativeCall`.

Types of the attributes are used whenever possible to drive behavior, with custom traits provided to add more smarts when needed to parse more formats.

These attributes are parsed in order of declaration, regardless of if they are public or private, but only attributes declared in that class directly. The readonly or rw traits are ignored for attributes. Methods are also ignored.

WARNING: As this is a pre-1.0 module, the API is subject to change between versions without deprecation.

TYPES
=====

Perl 6 provides a wealth of native sized types. The following native types may be used on attributes for parsing and building without the help of any traits:

  * int8

  * int16

  * int32

  * uint8

  * uint16

  * uint32

These types consume 1, 2, or 4 bytes as appropriate for the type. These values are interpreted as little endian by default. Big endian representations may be indicated by using the `is big-endian` trait, see the traits section below.

  * Buf

Buf is another type that lends itself to representing this data. It has no obvious length and requires the `read` trait to consume it (see the traits section below).

Note that you can provide both `is read` and `is written` to compute the value when parsing and building, allowing you to put in arbitrary bytes at this position. See `StreamPosition` below if you just want to keep track of the current position.

  * StaticData

A variant of Buf, `StaticData`, is provided to represent bytes that are known in advance. It requires a default value of a Buf, which is used to determine the number of bytes to consume, and these bytes are checked with the default value. An exception is raised if these bytes do not match. An appropriate use of this would be the magic bytes at the beginning of many file formats, or the null terminator at the end of a CString, for example:

    # Magic for PNG files
    class PNGFile is Binary::Structured {
	    has StaticData $.magic = Buf.new(0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a);
    }

  * StreamPosition

This exported class consumes no bytes, and writes no bytes. It just records the current stream position into this attribute when reading or writing so other variables can reference it later. Reader and writer traits are ignored on this attribute.

  * StreamEvent

This exported class consumes no bytes, and writes no bytes. It executes the `is read` and `is written` attributes, allowing you to put arbitrary code in the parse or build process at this point. This is a good place to put a call to `rewrite-attribute`, allowing you to update a previous value once you know what it should be.

  * Binary::Structured subclass

These structures may be nested. Provide an attribute that subclasses `Binary::Structured` to include another structure at this position. This inner structure takes over control until it is done parsing or building, and then the outer structure resumes parsing or building.

    class Inner is Binary::Structured {
	    has int8 $.value;
    }
    class Outer is Binary::Structured {
	    has int8 $.before;
	    has Inner $.inner;
	    has int8 $.after;
    }
    # This would be able to parse Buf.new(1, 2, 3)
    # $outer.before would be 1, $outer.inner.value would be 2,
    # and $outer.after would be 3.

  * Array[Binary::Structured]

Multiple structures can be handled by using an `Array` of subclasses. Use the `read` trait to control when it stops trying to adding values into the array. See the traits section below for examples on controlling iteration.

METHODS
=======

class X::Binary::Structured::StaticMismatch
-------------------------------------------

Exception raised when data in a C<StaticData> does not match the bytes consumed.

class Binary::Structured
------------------------

Superclass of formats. Some methods are meant for implementing various trait helpers (see below).

### has Int $.pos

Current position of parsing of the Buf.

### has Blob $.data

Data being parsed.

### method peek

```
method peek(
    Int $count
) returns Mu
```

Returns a Buf of the next C<$count> bytes but without advancing the position, used for lookahead in the C<is read> trait.

### method peek-one

```
method peek-one() returns Mu
```

Returns the next byte as an Int without advancing the position. More efficient than regular C<peek>, used for lookahead in the C<is read> trait.

### method pull

```
method pull(
    Int $count
) returns Mu
```

Method used to consume C<$count> bytes from the data, returning it as a Buf. Advances the position by the specified count.

### method pull-elements

```
method pull-elements(
    Int $count
) returns ElementCount
```

Helper method for reader methods to indicate a certain number of elements/iterations rather than a certain number of bytes.

### method rewrite-attribute

```
method rewrite-attribute(
    Str $attribute
) returns Mu
```

Helper method to rewrite a previous attribute that is marked C<is rewritten>. Only works on seekable buffers and may not change the length of the buffer. Specify the attribute via string using the C<$!foo> syntax (regardless of if it is public or private).

### method parse

```
method parse(
    Blob $data, 
    Int :$pos = 0
) returns Mu
```

Takes a Buf of data to parse, with an optional position to start parsing at.

### method build

```
method build() returns Blob
```

Construct a C<Buf> from the current state of this object.

TRAITS
======

Traits are provided to add additional parsing control. Most of them take methods as arguments, which operate in the context of the parsed (or partially parsed) object, so you can refer to previous attributes.

`is read`
---------

The `is read` trait controls reading of `Buf`s and `Array`s. For `Buf`, return a `Buf` built using `self.pull($count)` (to ensure the position is advanced properly). `$count` here could be a reference to a previously parsed value, could be a constant value, or you can use a loop along with `peek-one`/`peek` to concatenate to a Buf.

For `Array`, return a count of bytes as an `Int`, or return a number of elements to read using `self.pull-elements($count)`. Note that `pull-elements` does not advance the position immediately so `peek` is less useful here.

`is written`
------------

The `is written` trait controls how a given attribute is constructed when `build` is called. It provides a way to update values based on other attributes. It's best used on things that would be private attributes, like lengths and some checksums. Since `build` is only called when all attributes are filled, you can refer to attributes that have not been written (unlike `is read`).

`is big-endian`
---------------

Applies to native integers (int16, int32, uint16, uint32), and indicates that this value should be read and written as a big endian value (with the most significant byte first) rather than the default of little endian.

`is little-endian`
------------------

Little endian is the default for numeric values, but the trait is provided for completeness.

REQUIREMENTS
============

  * Rakudo Perl v6.c or above (tested on 2016.08.1)

TODO
====

See [TODO](TODO).
