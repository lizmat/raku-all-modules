NAME
====

IO::Glob - Glob matching for paths & strings and listing files

SYNOPSIS
========

    use IO::Glob;

    # Need a list of files somewhere?
    for glob("src/core/*.pm") -> $file { say ~$file }

    # Or apply the glob to a chosen directory
    with glob("*.log") {
        for .dir("/var/log/error") -> $err-log { ... }
        for .dir("/var/log/access") -> $acc-log { ... }
    }

    # Use a glob to match a string or path
    if "some-string" ~~ glob("some-*") { say "match string!" }
    if "some/path.txt".IO ~~ glob("some/*.txt") { say "match path!" }

    # Use a glob as a test in built-in IO::Path.dir()
    for "/var/log".IO.dir(test => glob("*.err")) -> $err-log { ... }

    # Globs are objects, which you can save, reuse, and pass around
    my $file-match = glob("*.txt);
    my @files := dir("$*HOME/docs", :test($file-match));

    # Want to use SQL globbing with % and _ instead?
    for glob("src/core/%.pm", :sql) -> $file { ... }

    # Or want globbing without all the fancy bits?
    # :simple turns off everything but * an ?
    for glob("src/core/*.pm", :simple) -> $file { ... }

DESCRIPTION
===========

Traditionally, globs provide a handy shorthand for identifying the files you're interested in based upon their path. This class provides that shorthand using a BSD-style glob grammar that is familiar to Perl devs. However, it is more powerful than its Perl 5 predecessor.

  * Globs are built as IO::Glob objects which encapsulate the pattern. You may create them and pass them around.

  * By using them as an iterator, you can put globs to their traditional use: listing all the files in a directory.

  * Globs also work as smart-matches. It will match against strings or anything that stringifies and against [IO::Path](IO::Path)s too.

  * Globbing can be done with different grammars. This class ships with three: simple, BSD, and SQL.

  * **Experimental.** You can use custom grammars for your smart match.

SUBROUTINES
===========

sub glob
--------

    sub glob(
        Str:D $pattern,
        Bool :$sql,
        Bool :$bsd,
        Bool :$simple,
        :$grammar,
        :$spec = $*SPEC
    ) returns IO::Glob:D

    sub glob(
        Whatever $,
        Bool :$sql,
        Bool :$bsd,
        Bool :$simple,
        :$grammar,
        :$spec = $*SPEC
    ) returns IO::Glob:D

When given a string, that string will be stored in the [#method pattern/pattern](#method pattern/pattern) attribute and will be parsed according to the [#method grammar/grammar](#method grammar/grammar).

When given [Whatever](Whatever) (`*`) as the argument, it's the same as:

    glob('*');

which will match anything. (Note that what whatever matches may be grammar specific, so `glob(*, :sql)` is the same as `glob('%')`.)

If you want to pick from one of the built-in grammars, you may use these options:

  * `:bsd` is the default specifying this is explicit, but unnecessary. This grammar supports `*`, `?`, `[abc]`, `[!abc]`, `~`, and `{ab,cd,efg}`.

  * `:sql` uses a SQL-ish grammar that provides `%` and `_` matching.

  * `:simple` is a simplified version of `:bsd`, but only supports `*` and `?`.

The `:$spec` option allows you to specify the [IO::Spec](IO::Spec) to use when matching paths. It uses `$*SPEC`, by default. The IO::Spec is used to split paths by directory separator when matching paths. (This is ignored when matching against other kinds of objects.)

An alternative to this is to use the optional `:$grammar` setting lets you select a globbing grammar object to use. These are provided:

  * IO::Glob::BSD

  * IO::Glob::SQL

  * IO::Glob::Simple

**Experimental.** If you want a different grammar, you may create your own as well, but no documentation of that process has been written yet as of this writing.

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

    method dir(Cool $path = '.') returns Seq:D

Returns a list of files matching the glob. This will descend directories if the pattern contains a [IO::Spec#dir-sep](IO::Spec#dir-sep) using a depth-first search. This method is called implicitly when you use the object as an iterator. For example, these two lines are identical:

    for glob('*.*') -> $all-dos-files { ... }
    for glob('*.*').dir -> $all-dos-files { ... }

**Caveat.** This ought to respect the order of alternates in expansions like `{bc,ab}`, but that is not supported yet at this time.

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
