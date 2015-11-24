p6-c-parser
===========

Grammar for Parsing C in Perl6


Introduction
------------

*WARNING* This parser is not production ready. It is experimental, and a work in progress.
If you would like to try it out, the recommended way is:

`my $ast = C::Parser.parse($source);`


Another thing to note is that it doesn't provide any understanding of C preprocessor
directives, so you will have to use `gcc -E` (or the like) before parsing it. This
can usually be accomplished by:

`gcc -E FILE.c | grep -v '^#' | bin/cdump.pl6`

Typedefs
--------

Probably the major surprizing thing about this parser is that it doesn't work for
obvious inputs, such as `GHashTable hash;`. The reason for this is that the parser
has built-in rules that match based on whether an identifier has been previously
involved in a `typedef` declaration. So if your source code compiles with a fully
functional compiler, then it should also parse with this parser. But if your source
code just happens to match the syntactic definition of C, but not the semantics,
then good luck, dude.

For this reason, there are a lot of types that are pre-declared to help ease the
pain associated with this issue. Most of them are types that are usually found
in system-supplied libraries, such as `libc` and POSIX. For example, types such
as `FILE` and `int64_t` are pre-declared. If you feed a preprocessed source
that had include "stdint.h" in it, then the parser will see a `typedef` for
`int64_t` at some point. This is perfectly fine. A type can be `typedef`ed
multiple times and it will still parse, but not 0 times.

Conclusion
----------

Don't write a compiler with this just yet.

