[![Build Status](https://travis-ci.org/moznion/p6-IO-Blob.svg?branch=master)](https://travis-ci.org/moznion/p6-IO-Blob)

NAME
====

IO::Blob - IO:: interface for reading/writing a Blob

SYNOPSIS
========

    use v6;
    use IO::Blob;

    my $data = "foo\nbar\n";
    my IO::Blob $io = IO::Blob.new($data.encode);

    $io.get; # => "foo\n"

    $io.print('buz');

    $io.seek(0, 0); # rewind

    $io.slurp-rest; # => "foo\nbar\nbuz"

DESCRIPTION
===========

`IO::` interface for reading/writing a Blob. This class inherited from [IO::Handle](IO::Handle).

The IO::Blob class implements objects which behave just like IO::Handle objects, except that you may use them to write to (or read from) Blobs.

This module is inspired by IO::Scalar of perl5.

METHODS
=======

new(Blob $data = Buf.new)
-------------------------

Make a instance. This method is equivalent to `open`.

    my $io = IO::Blob.new("foo\nbar\n".encode);

open(Blob $data = Buf.new)
--------------------------

Make a instance. This method is equivalent to `new`.

    my $io = IO::Blob.open("foo\nbar\n".encode);

new(Str $str)
-------------

Make a instance. This method is equivalent to `open`.

    my $io = IO::Blob.new("foo\nbar\n");

open(Str $str)
--------------

Make a instance. This method is equivalent to `new`.

    my $io = IO::Blob.open("foo\nbar\n");

get(IO::Blob:D:)
----------------

Reads a single line from the Blob.

    my $io = IO::Blob.open("foo\nbar\n".encode);
    $io.get; # => "foo\n"

getc(IO::Blob:D:)
-----------------

Read a single character from the Blob.

    my $io = IO::Blob.open("foo\nbar\n".encode);
    $io.getc; # => "f\n"

lines(IO::Blob:D: $limit = Inf)
-------------------------------

Return a lazy list of the Blob's lines read via `get`, limited to `$limit` lines.

    my $io = IO::Blob.open("foo\nbar\n".encode);
    for $io.lines -> $line {
        $line; # 1st: "foo\n", 2nd: "bar\n"
    }

word(IO::Blob:D:)
-----------------

Read a single word (separated on whitespace) from the Blob.

    my $io = IO::Blob.open("foo bar\tbuz\nqux".encode);
    $io.word; # => "foo "

words(IO::Blob:D: $count = Inf)
-------------------------------

Return a lazy list of the Blob's words (separated on whitespace) read via `word`, limited to `$count` words.

    my $io = IO::Blob.open("foo bar\tbuz\nqux".encode);
    for $io.words -> $word {
        $word; # 1st: "foo ", 2nd: "bar\t", 3rd: "buz\n", 4th: "qux"
    }

print(IO::Blob:D: *@text) returns Bool
--------------------------------------

Text writing; writes the given `@text` to the Blob.

read(IO::Blob:D: Int(Cool:D) $bytes)
------------------------------------

Binary reading; reads and returns `$bytes` bytes from the Blob.

write(IO::Blob:D: Blob:D $buf)
------------------------------

Binary writing; writes $buf to the Blob.

seek(IO::Blob:D: int $offset, int $whence)
------------------------------------------

Move the pointer (that is the position at which any subsequent read or write operations will begin,) to the byte position specified by `$offset` relative to the location specified by `$whence` which may be one of:

  * 0

The beginning of the file.

  * 1

The current position in the file.

  * 2

The end of the file.

tell(IO::Blob:D:) returns Int
-----------------------------

Returns the current position of the pointer in bytes.

ins(IO::Blob:D:) returns Int
----------------------------

Returns the number of lines read from the file.

slurp-rest(IO::Blob:D: :$bin!) returns Buf
------------------------------------------

Return the remaining content of the Blob from the current position (which may have been set by previous reads or by seek.) If the adverb `:bin` is provided a Buf will be returned.

slurp-rest(IO::Blob:D: :$enc = 'utf8') returns Str
--------------------------------------------------

Return the remaining content of the Blob from the current position (which may have been set by previous reads or by seek.) Return will be a Str with the optional encoding `:enc`.

eof(IO::Blob:D:)
----------------

Returns [Bool::True](Bool::True) if the read operations have exhausted the content of the Blob;

close(IO::Blob:D:)
------------------

Will close a previously opened Blob.

is-closed(IO::Blob:D:)
----------------------

Returns [Bool::True](Bool::True) if the Blob is closed.

data(IO::Blob:D:)
-----------------

Returns the current Blob.

SEE ALSO
========

[IO::Scalar of perl5](https://metacpan.org/pod/IO::Scalar)

AUTHOR
======

moznion <moznion@gmail.com>

CONTRIBUTORS
============

  * mattn

  * shoichikaji

LICENSE
=======

Copyright 2015 moznion <moznion@gmail.com>

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
