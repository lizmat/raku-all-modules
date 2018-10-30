# Uni63 [![Build Status](https://travis-ci.org/cygx/p6-uni63.svg?branch=master)](https://travis-ci.org/cygx/p6-uni63)

A Unicode encoding scheme suitable for name mangling

# Synopsis

```
    use Uni63;

    my $enc = Uni63::enc('Leberkäse');
    my $dec = Uni63::dec($enc);
```

# Description

The 62 alphanumeric ASCII characters encode themselves. A 63rd character `_` is
used to mark escape sequences.

The escape character is followed by a single digit, indicating the number of
characters that encode the next Unicode codepoint. Contrary to the module name,
the codepoint is encoded in base-62 with digits `0..9`, `a..z`, `A..Z`.

The decoder does not validate its input:

  * An invalid character or an underscore that is not followed by a valid
    escape sequence will be passed through, thus re-encoding a decoded string
    may not round trip.

  * The numeric value of any escape sequence that follows the given scheme
    will be passed on to `chr`, even if the value lies outside the range of
    Unicode codepoints.


# Bugs and Development

Development happens at [GitHub](https://github.com/cygx/p6-uni63). If you
found a bug or have a feature request, use the
[issue tracker](https://github.com/cygx/p6-uni63/issues) over there.


# Copyright and License

Copyright (C) 2015 by <cygx@cpan.org>

Distributed under the
[Boost Software License, Version 1.0](http://www.boost.org/LICENSE_1_0.txt)
