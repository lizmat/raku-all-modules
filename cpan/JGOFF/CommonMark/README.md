[![Build Status](https://travis-ci.org/drforr/perl6-CommonMark.svg?branch=master)](https://travis-ci.org/drforr/perl6-CommonMark)

CommonMark
==========

Interface to the [libcmark](libcmark) CommonMark parser

Synopsis
========

    use CommonMark;

    say CommonMark.to-html("Hello, world!");
    # "<p>Hello, world!</p>"

    say CommonMark.version-string;
    # 0.28.3

Documentation
=============

CommonMark is Markdown with a proper spec - It should render most Markdown files the same; it nails down some edge cases, and specifies byte encodings.

You'll want to call `.to-html($text)` to convert markdown to HTML. The library itself also supports XML, LaTeX, and nroff/troff formats, but I haven't seen where it's tested. Check out the Perl 6 source for more details there.

CommonMark class
================

METHODS
-------

  * to-html( $common-mark )

Return HTML from CommonMark format. This is likely the only method you'll use. There's a lower-level interface that'll let you interrogate the library at the individual node level, look at the source for more inspiration.

  * version()

Returns a 32-bit int containing the version number.

From the documetation:

    * Bits 16-23 contain the major version.
    * Bits 8-15 contain the minor version.
    * Bits 0-7 contain the patchlevel.

  * version-string()

Returns the library version in text form.

  * parse-document( Str $buffer, int32 $options )

Returns a CommonMark::Node root of the document.

CommonMark::Node class
======================

  * new( :$type )

Create a new CommonMark node with the specified type - this isn't well-documented in the library, so please read the source.

  * next()

Return this node's successor in the multiply-linked list

  * previous()

Return this node's predecessor in the multiply-linked list

  * parent()

Return this node's parent in the multiply-linked list

  * first-child()

Return this node's first child within the multiply-linked list

  * last-child()

Return this node's last child within the multiply-linked list

  * user-data()

Return this node's user data (generic pointer)

  * user-data( Pointer $ptr )

Set user data pointer

  * type()

Return this node's type number

  * type-string()

Return this node's type as a string

  * literal()

Return this node's literal string

  * literal( Str $str )

Set this node's literal string

  * heading-level()

Return this node's heading level

  * heading-level( int32 $level )

Set this node's heading level

  * list-type()

Return this node's list type

  * list-type( int32 $level )

Set this node's list type

  * list-delim()

Return this node's list delimiter

  * list-delim( int32 $level )

Set this node's list delimiter

  * list-start()

Return this node's list start

  * list-start( int32 $level )

Set this node's list start

  * list-tight()

Return this node's list tightness

  * list-tight( int32 $level )

Set this node's list tightness

  * fence-info()

Return this node's fence information

  * fence-info( Str $info )

Set this node's fence information

  * url()

Return this node's URL content

  * url( Str $url )

Set this node's URL content

  * title()

Return this node's title

  * title( Str $title )

Set this node's title

  * on-enter()

Return this node's on-enter string

  * on-enter( Str $title )

Set this node's on-enter string

  * on-exit()

Return this node's on-exit string

  * on-exit( Str $title )

Set this node's on-exit string

  * start-line()

Return this node's starting line

  * start-column()

Return this node's starting column

  * end-line()

Return this node's end line

  * end-column()

Return this node's end column

  * unlink()

Unlink this node from the tree.

  * insert-before( CommonMark::Node $node )

Insert `$node` before this node

  * insert-after( CommonMark::Node $node )

Insert `$node` after this node

  * replace( CommonMark::Node $node )

Replace this node with `$node`

  * prepend-child( CommonMark::Node $node )

Prepend `$node` below this node

  * append-child( CommonMark::Node $node )

Append `$node` below this node

  * consolidate-text-nodes()

Consolidate the text nodes in this node

  * render-xml( int32 $options )

Render this node as XML, with the appropriate options `$options`

  * render-html( int32 $options )

Render this node as HTML, with the appropriate options `$options`

  * render-man( int32 $options, int32 $width )

Render this node as a manpage, with the appropriate options `$options`, `$width`

  * render-commonmark( int32 $options, int32 $width )

Render this node as the original CommonMark text, with the appropriate options `$options` and `$idth`

  * render-latex( int32 $options, int32 $width )

Render this node as LaTeX, with the appropriate options `$options`, `$width`

  * check( int32 $file-ID )

Check this node with file descriptor $file-ID

CommonMark::Iterator class
==========================

  * next()

Return the next item in this iterator

  * node()

Return the current node for the iterator

  * event-type()

Return the current event type

  * root()

Return the root for the iterator

  * reset( CommonMark::Node $current, int32 $event-type )

Reset the iterator to node `$current`, type `$event-type`

CommonMark::Parser class
========================

  * feed( Str $buffer )

Feed the buffer to the parser

  * finish()

Finish parsing the document

