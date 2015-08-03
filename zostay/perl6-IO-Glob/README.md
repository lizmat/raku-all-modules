NAME
====

IO::Glob - Glob matching for paths & strings and listing files

[![Build Status](https://travis-ci.org/zostay/perl6-IO-Glob.svg)](https://travis-ci.org/zostay/perl6-IO-Glob)

SYNOPSIS
========

    use IO::Glob;

    # Use a glob to match a string or path
    if "some-string" ~~ glob("some-*") { say "match string!" }
    if "some/path.txt".IO ~~ glob("some/*.txt") { say "match path!" }

    # Use a glob as a test in built-in IO::Path.dir()
    for "/var/log".IO.dir(test => glob("*.err")) -> $err-log { ... }

    # Or better, do it directly from here
    for glob("*.err").dir("/var/log") -> $err-log { ... }

    # Globs are objects, which you can save, reuse, and pass around
    my $file-match = glob("*.txt);
    my @files := dir("$*HOME/docs", :test($file-match));

DESCRIPTION
===========

Traditionally, globs provide a handy shorthand for identifying the files you're interested in based upon their path. This class provides that shorthand using a BSD-style glob grammar that is familiar to Perl devs. However, it is more powerful than it's predecessor in Perl 5's File::Glob.

  * Globs are built as IO::Glob objects which encapsulate the pattern and let you pass them around for whatever use you want to put them too.

  * By using [#method dir](#method dir), you can put globs to their traditional use, listing all the files in a directory.

  * It also works well as a smart-match. It will match against strings or anything that stringifies and against [IO::Path](IO::Path)s too. This allows it to be used with the built-in [IO::Path#method dir](IO::Path#method dir) too.

  * You can use custom grammars for your smart match. This is still somewhat experimental, but if you need a different glob style that is provided, you can roll your own with a small amount of effort or extend on of the existing ones. This class ships with three grammars: Simple, BSD, and SQL.

SUBROUTINES
===========

sub glob
--------

    sub glob(Str:D $pattern, :$grammar = IO::Glob::BSD.new, :$spec = $*SPEC) returns IO::Glob:D
    sub glob(Whatever $, :$grammar = IO::Glob::BSD.new, :$spec = $*SPEC) returns IO::Glob:D

When given a string, that string will be stored in the [#method pattern/pattern](#method pattern/pattern) attribute and will be parsed according to the [#method grammar/grammar](#method grammar/grammar).

When given [Whatever](Whatever) (`*`) as the argument, it's the same as:

    glob('*');

which will match anything. (Note that what whatever matches may be grammar specific, so `glob(*, :grammar(IO::Glob::SQL))` is the same as `glob('%')`.)

The optional `:$grammar` setting lets you select a globbing grammar to use. Two are provided:

  * IO::Glob::Simple (which supports just `*` and `?`)

  * IO::Glob::BSD (supports `*`, `?`, `[abc]`, `[!abc]`, `~`, and `{ab,cd,efg}`)

  * IO::Glob::SQL (supports `%` and `_`)

If you want a grammar that does something else, you may create your own as well, but no documentation of that process has been written yet as of this writing.

Finally, the `:$spec` option allows you to specify the [IO::Spec](IO::Spec) to use when matching paths. It uses `$*SPEC`, by default.

METHODS
=======

method pattern
--------------

    method pattern() returns Str:D

Returns the pattern set during construction.

method spec
-----------

    method spec() returns IO::Spec:D

Returns the spec set during construction.

method grammar
--------------

    method grammar() returns Any:D

Returns the grammar set during construction.

method dir
----------

    method dir(Cool $path = '.') returns List:D

Returns a list of files matching the glob. This will descend directories if the pattern contains a [IO::Spec#dir-sep](IO::Spec#dir-sep) using a depth-first search. (This ought to respect the order of alternates in expansions like `{bc,ab}`, but that is not supported yet at this time.)

method ACCEPTS
--------------

    method ACCEPTS(Mu:U $) returns Bool:D
    method ACCEPTS(Str:D(Any) $candiate) returns Bool:D
    method ACCEPTS(IO::Path:D $path) returns Bool:D

This implements smart-match. Undefined values never match. Strings are matched using the whole pattern, without reference to any directory separators in the string. Paths, however, are matched and carefully respect directory separators. For most circumstances, this will not make any difference. However, a case like this will be treated very differently in each case:

    my $glob = glob("hello{x,y/}world");
    say "String" if "helloy/world" ~~ $glob;      # outputs> String
    say "Path"   if "helloy/world".IO ~~ $glob;   # outputs nothing, no match
    say "Path 2" if "helloy{x,y/}world" ~~ $glob; # outputs> Path 2

The reason is that the second and third are matched in parts as follows:

    "helloy" ~~ glob("hello{x,y") && "world" ~~ glob("}world")
    "hello{x,y" ~~ glob("hello{x,y") && "}world" ~~ glob("}world")
