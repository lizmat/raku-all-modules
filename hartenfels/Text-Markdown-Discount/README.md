[![Build Status](https://travis-ci.org/hartenfels/Text-Markdown-Discount.svg?branch=master)](https://travis-ci.org/hartenfels/Text-Markdown-Discount)

NAME
====

Text::Markdown::Discount - markdown to HTML using the Discount C library

VERSION
=======

0.2.5

SYNOPSIS
========

    use Text::Markdown::Discount;
    my $raw-md = '# Hello `World`!'

    # render HTML into string...
    say markdown($raw-md       ); # from a string
    say markdown('README.md'.IO); # from a file, note the `.IO`

    # ...or directly into files
    markdown($raw-md,        'sample.html');
    markdown('README.md'.IO, 'README.html');

You can also use the various [#Flags](#Flags) in Discount:

    say markdown($raw-md, :autolink, :!image ); # MKD_AUTOLINK | MKD_NOIMAGE
    say markdown($raw-md, :AUTOLINK, :NOIMAGE); # same thing

The API from [Text::Markdown](https://github.com/retupmoca/p6-markdown/) is also supported:

    my $md = Text::Markdown::Discount.new($raw-md);
    say $md.render;

    $md = parse-markdown($raw-md);
    say $md.to-html;
    say $md.to_html; # same thing

DESCRIPTION
===========

libmarkdown
-----------

This library provides bindings to the [Discount library](https://github.com/Orc/discount) via [NativeCall](NativeCall). You need to have it installed as the `libmarkdown` shared library.

On Ubuntu 15.04, it's available via `apt-get` as the `libmarkdown2-dev` package, the same goes for several Debians. If it's not available as a binary for your system, you can compile it [from source](https://github.com/Orc/discount).

Simple API
----------

### markdown

    sub markdown(    Cool:D $str,  Cool $to-file?, *%flags --> Cool) is export
    sub markdown(IO::Path:D $file, Cool $to-file?, *%flags --> Cool) is export

This function is probably enough for most cases. It will either take the markdown from the given `$str` or `$file` and convert it to HTML. If `$to-file` is given, the result will be written to the file at that path and returns `True`. Otherwise returns a `Str` with the HTML in it.

Will throw an exception if there's a problem reading or writing files, or if the markdown can't be converted for some reason.

See [#Flags](#Flags) about the `*%flags` parameter.

Object API
----------

### from-str

    method from-str(Cool $str, *%flags --> Text::Markdown::Discount:D)

Parses the given `$str` as markdown and returns an object you can call HTML conversion methods on.

You can call this method on both a class and an object instance.

See [#Flags](#Flags) about the `*%flags` parameter.

### from-file

    method from-file(Cool $file, *%flags --> Text::Markdown::Discount:D)

As [#from-str](#from-str), except will read the markdown from the given `$file`.

Will `fail` with an [#X::Text::Markdown::Discount::File](#X::Text::Markdown::Discount::File) if it can't `fopen` the given `$file` and `warn` if it can't `fclose` it.

### to-str

    method to-str(Text::Markdown::Discount:D: --> Str)

Converts the markdown in the caller into HTML and returns the result.

Will `fail` with a [#X::Text::Markdown::Discount::File](#X::Text::Markdown::Discount::File) if Discount can't compile the markdown for some reason.

### to-file

    method to-file(Text::Markdown::Discount:D: Str $file --> Bool)

Converts the markdown in the caller into HTML and writes the result to the given `$file`. Returns `True` or an appropriate `Failure`.

### dump-flags

    multi method dump-flags(Int:D $fd = 1)
    multi method dump-flags(Str:D $file)

Dumps all flag options applied to the caller. Either to the given `$file` path, or to the file descriptor `$fd`. Defaults to dumping to file descriptor 1 (stderr).

This function may be useful in figuring out if the Discount library you're linked to actually has the flags you need.

Text::Markdown Compatibility
----------------------------

These functions exist so that you can use `Text::Markdown::Discount` as a drop-in replacement for [Text::Markdown](https://github.com/retupmoca/p6-markdown/). They just dispatch to existing functions:

### new

### parse-markdown

    multi method new($text, *%flags)
    sub parse-markdown($text *%flags) is export

Dispatch to [#from-str](#from-str).

### render

### to-html

### to_html

    method render()
    method to-html()
    method to_html()

Dispatch to [#to-str](#to-str).

Exceptions
----------

### X::Text::Markdown::Discount

    class X::Text::Markdown::Discount is Exception

The base exception class for this module. All other exception types inherit from this. Not actually thrown directly.

### X::Text::Markdown::Discount::File

    class X::Text::Markdown::Discount::File is X::Text::Markdown:Discount

Thrown when an `fopen`, `fdopen` or `fclose` fails. The latter will only be a warning.

### X::Text::Markdown::Discount::Flag

    class X::Text::Markdown::Discount::Flag is X::Text::Markdown:Discount

Thrown when you try to use a non-existent flag.

### X::Text::Markdown::Discount::Compile

    class X::Text::Markdown::Discount::Compile is X::Text::Markdown:Discount

Thrown when Discount can't compile markdown. I can't tell when this would happen or where to get the error message from though.

Flags
-----

Discount provides a variety of flags that change how the conversion behavior. You can pass flags to all routines that take a `*%flags` parameter.

The following list of flags is taken from [Discount's documentation](http://www.pell.portland.or.us/~orc/Code/discount/). Depending on your version of the library, they might not all be available, see [#dump-flags](#dump-flags).

All of these flags map to the respective `MKD_` constants. The keys are case-insensitive. Constants that originally start with `NO` can be used without it and negated. For example, `:!links` is the same as `:nolinks`.

`:!links`, `:nolinks`

Don't do link processing, block `<a> ` tags.

`:!image`, `:noimage`

Don't do image processing, block `<img> `.

`:!pants`, `:nopants`

Don't run `smartypants()`

`:!html`, `:nohtml`

Don't allow raw html through **AT ALL**.

`:strict`

Disable `SUPERSCRIPT`, `RELAXED_EMPHASIS`.

`:tagtext`

Process text inside an html tag; no `<em> `, no `<bold> `, no html or `[]` expansion.

`:!ext`, `:noext`

Don't allow pseudo-protocols.

`:cdata`

Generate code for xml `![CDATA[...]]`.

`:!superscript`, `:nosuperscript`

No `A^B`.

`:!relaxed`, `:norelaxed`

Emphasis happens *everywhere*.

`:!tables`, `:notables`

Don't process [PHP Markdown Extra](http://michelf.com/projects/php-markdown/extra/) tables.

`:!strikethrough`, `:nostrikethrough`

Forbid `~~strikethrough~~`.

`:toc`

Do table-of-contents processing.

`:compat`

Compatability with MarkdownTest_1.0.

`:autolink`

Make `http://foo.com` a link even without `<> `s.

`:safelink`

Paranoid check for link protocol.

`:!header`, `:noheader`

Don't process document headers.

`:tabstop`

Expand tabs to 4 spaces.

`:!divquote`, `:nodivquote`

Forbid `>%class% ` blocks.

`:!alphalist`, `:noalphalist`

Forbid alphabetic lists.

`:!dlist`, `:nodlist`

Forbid definition lists.

`:extra_footnote`

Enable [PHP Markdown Extra](http://michelf.com/projects/php-markdown/extra/)-style footnotes.

BUGS
====

There's probably some bugs in the NativeCall handling. I'm not sure if the types are specified correctly and if the destructor for the native pointers gets called when it needs to.

There seems to be a bug in Discount's `mkd_generatehtml` function, where it adds excessive `nul`s to the output if it has previously been compiled to a string. Due to that, the [#to-file](#to-file) currently just `spurt`s the string output into the file.

Please report bugs [on GitHub](https://github.com/hartenfels/Text-Markdown-Discount/issues).

TODO
====

  * Depend on `Native::LibC` for `FILE` stuff

  * Make sure that my NativeCall usage is correct

  * Finish this documentation

AUTHOR
======

[Carsten Hartenfels](mailto:carsten.hartenfels@googlemail.com)

SEE ALSO
========

[Text::Markdown](https://github.com/retupmoca/p6-markdown/), [Discount](http://www.pell.portland.or.us/~orc/Code/discount/), [Discount GitHub repository](https://github.com/Orc/discount), [Text::Markdown::Discount for Perl 5](https://metacpan.org/pod/Text::Markdown::Discount).

COPYRIGHT AND LICENSE
=====================

This software is copyright (c) 2015 by Carsten Hartenfels.

This program is distributed under the terms of the Artistic License 2.0.

For further information, please see LICENSE or visit <http://www.perlfoundation.org/attachment/legal/artistic-2_0.txt>.
