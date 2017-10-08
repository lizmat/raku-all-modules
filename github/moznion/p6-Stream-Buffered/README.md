[![Build Status](https://travis-ci.org/moznion/p6-Stream-Buffered.svg?branch=master)](https://travis-ci.org/moznion/p6-Stream-Buffered)

NAME
====

Stream::Buffered - Temporary buffer to save bytes

SYNOPSIS
========

    use Stream::Buffered;

    my $buf = Stream::Buffered.new($length);

    $buf.print("foo");
    my Int $size = $buf.size;
    my IO::Handle $io = $buf.rewind;

DESCRIPTION
===========

Stream::Buffered is a buffer class to store arbitrary length of byte strings and then get a seekable IO::Handle once everything is buffered. It uses Blob and temporary file to save the buffer depending on the length of the size.

This library is a perl6 port of [perl5's Stream::Buffered](https://metacpan.org/pod/Stream::Buffered).

METHODS
=======

`new(Int $length, Int $maxMemoryBufferSize = 1024 * 1024) returns Stream::Buffered`
-----------------------------------------------------------------------------------

Creates instance.

When you specify negative value as `$maxMemoryBufferSize`, Stream::Buffered always uses Blob as buffer. Or when you specify 0 as `$maxMemoryBufferSize`, Stream::Buffered always uses temporary file as buffer.

If you pass 0 to the first argument, Stream::Buffered decides what kind of buffer type (Blob or temp file) to use automatically.

`print(Stream::Buffered:D: *@text) returns Bool`
------------------------------------------------

Append text to buffer.

`size(Stream::Buffered:D:) returns Int`
---------------------------------------

Return the size of buffer.

`rewind(Stream::Buffered:D:) returns IO::Handle`
------------------------------------------------

Seek to the head of buffer and return buffer.

SEE ALSO
========

  * [perl5's Stream::Buffered](https://metacpan.org/pod/Stream::Buffered)

AUTHOR
======

moznion <moznion@gmail.com>

COPYRIGHT AND LICENSE
=====================

    Copyright 2015 moznion

    This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

And original perl5's Stream::Buffered is

    The following copyright notice applies to all the files provided in
    this distribution, including binary files, unless explicitly noted
    otherwise.

    Copyright 2009-2011 Tatsuhiko Miyagawa

    This library is free software; you can redistribute it and/or modify
    it under the same terms as Perl itself.
