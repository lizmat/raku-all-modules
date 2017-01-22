# Unicode::GCB [![Build Status][1]][2]

Unicode grapheme cluster boundary detection

# Synopsis

```
    use Unicode::GCB;

    say GCB.always(0x600, 0x30);
    say GCB.maybe(
        "\c[REGIONAL INDICATOR SYMBOL LETTER G]".ord,
        "\c[REGIONAL INDICATOR SYMBOL LETTER B]".ord);

    say GCB.clusters("äöü".NFD);
```

# Description

Implements the Unicode 9.0 [grapheme cluster boundary rules][6].

In contrast to earlier versions of the standard, it is no longer possible
to unambiguously decide if there's a cluster break between two Unicode
characters by looking at just these two characters.

In particular, there's a break between a pair of regional indicator symbols
only if the first symbol has already been paired up with another indicator
and there's no break between extension characters and emoji modifiers if the 
current cluster forms an emoji sequence.

Therefore, the module provides two different methods `GCB.always()` and
`GCB.maybe()` which both expect two Unicode codepoints as arguments.

The method `GCB.clusters()` expects a `Uni` object as argument and returns
a sequence of such objects split along cluster boundaries.


# Bugs and Development

Development happens at [GitHub][3]. If you found a bug or have a feature
request, use the [issue tracker][4] over there.


# Copyright and License

Copyright (C) 2016 by <cygx@cpan.org>

Distributed under the [Boost Software License, Version 1.0][5]

[1]: https://travis-ci.org/cygx/p6-unicode-gcb.svg?branch=master
[2]: https://travis-ci.org/cygx/p6-unicode-gcb
[3]: https://github.com/cygx/p6-unicode-gcb
[4]: https://github.com/cygx/p6-unicode-gcb/issues
[5]: http://www.boost.org/LICENSE_1_0.txt
[6]: http://www.unicode.org/reports/tr29/tr29-29.html#Grapheme_Cluster_Boundary_Rules
