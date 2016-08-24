NAME
====

Test::Deeply::Relaxed - Compare two complex data structures loosely

SYNOPSIS
========

        use Test;
        use Test::Deeply::Relaxed;

        is-deeply-relaxed 'foo', 'foo';
        isnt-deeply-relaxed 'foo', 'bar';

        is-deeply-relaxed 5, 5;
        isnt-deeply-relaxed 5, '5';

        is-deeply-relaxed [1, 2, 3], Array[Int:D].new(1, 2, 3);

        is-deeply-relaxed {:a("foo"), :b("bar")}, Hash[Str:D].new({ :a("foo"), :b("bar") });

        # And now for the one that made me write this...
        my Array[Str:D] %opts;
        %opts<v> = Array[Str:D].new("v", "v");
        %opts<i> = Array[Str:D].new("foo.txt", "bar.txt");
        is-deeply-relaxed %opts, {:v([<v v>]), :i([<foo.txt bar.txt>]) };

        # It works with weirder types, too
        is-deeply-relaxed bag(<a b a a>), { a => 3, b => 1 }.Mix;
        isnt-deeply-relaxed bag(<a b a a>), { a => 2, b => 1 }.Mix;
        isnt-deeply-relaxed bag(<a b a a>), { a => 3, b => 1.5 }.Mix;

DESCRIPTION
===========

The `Test:::Deeply::Relaxed` module provides the `is-deeply-relaxed()` and `isnt-deeply-relaxed()` functions that do not check the state of mind of the passed objects, but instead compare their structure in depth similarly to `is-deeply()`, but a bit more loosely. In particular, they ignore the differences between typed and untyped collections, e.g. they will consider an array and an explicit `Array[Str:D]` to be the same if the strings contained within are indeed the same.

FUNCTIONS
=========

  * sub is-deeply-relaxed

        sub is-deeply-relaxed($got, $expected, $name = Str, Bool:D :$cache = False)

    Compare the two data structures in depth similarly to `is-deeply()`, but a bit more loosely.

    If the `:cache` flag is specified, the cache of values will be used for any iterable objects that support it. This allows the caller to later examine the sequences further.

  * sub isnt-deeply-relaxed

        sub isnt-deeply-relaxed($got, $expected, $name = Str, Bool:D :$cache = False)

    The opposite of `is-deeply-relaxed()` - fail if the two structures are loosely the same.

AUTHOR
======

Peter Pentchev <[roam@ringlet.net](mailto:roam@ringlet.net)>

COPYRIGHT
=========

Copyright (C) 2016 Peter Pentchev

LICENSE
=======

The Test::Deeply::Relaxed module is distributed under the terms of the Artistic License 2.0. For more details, see the full text of the license in the file LICENSE in the source distribution.
