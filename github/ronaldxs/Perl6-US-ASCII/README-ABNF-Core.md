NAME
====

US-ASCII::ABNF::Core - tokens for ABNF Core rules from RFC 5234

SYNOPSIS
========

```perl6
use US-ASCII::ABNF::Core;

grammar IPv4 is US-ASCII::ABNF::Core {
    token TOP   {
        <dec-octet> '.' <dec-octet> '.' <dec-octet> '.' <dec-octet>
    }
    token dec-octet         {
        '25' <[0..5]>           |   # 250 - 255
        '2' <[0..4]> <DIGIT>    |   # 200 - 249
        '1' <DIGIT> ** 2        |   # 100 - 199
        <[1..9]> <DIGIT>        |   # 10 - 99
        <DIGIT>                     # 0 - 9
    }
}
say so IPv4.parse("199.2.167.5");   # True
say so IPv4.parse("199.૫.167.5");   # False
```

```perl6
use US-ASCII::ABNF::Core :ALL;

say so 'DÉÃD' ~~ /^<ALPHA>*$/;  # False
say so 'BEEF' ~~ /^<ALPHA>*$/;  # True
```

DESCRIPTION
===========

Provides ABNF Core tokens, as specified in RFC 5234, for composition
into grammar by inheritance or import for direct use in regexes and
parsing. The tokens may also be composed using role
`US-ASCII::ABNF::Core-r`.

Tokens
======

  * ALPHA

  * BIT

  * CHAR

  * CR

  * CRLF

  * CTL

  * DIGIT

  * DQUOTE

  * HEXDIG

  * HTAB

  * LF

  * LWSP

  * OCTET

  * SP

  * VCHAR

  * WSP

LIMITATIONS
===========

Perl 6 strings treat `"\c[CR]\c[LF]"` as a single grapheme and that
sequence will not match either `<CR>` or `<LF>` but will match
`<CRLF>`.

The Unicode `\c[KELVIN SIGN]` at code point `\x[212A]` is normalized
by Perl 6 string processing to the letter 'K' and `say so "\x[212A]"
~~ /K/ ` prints `True`. Regex tests that match the letter K, including
US-ASCII::ABNF::Core tokens, may thus appear to match the Kelvin sign.

Export of tokens
================

Export of tokens and other `Regex` types is not formally documented.
Regex(es) are derived from `Method` which is in turn derived from
`Routine`. `Sub` is also derived from `Routine` and well documented
and established as exportable including lexical `my sub`. There is a
roast example of exporting an operator method in
S06-operator-overloading/infix.t and also mention of method export in
a Dec 12, 2009 advent blog post. Further documentation and test of
export on `Method` and `Regex` types is of interest to these modules
and project.

This implementation uses `my`/lexical scope to export tokens the same
way a module would export a `my sub`. I looked into `our` scope and no
scope specifier for the declarations and came across [roast issue
#426](https://github.com/perl6/roast/issues/426), which I felt made
the choice ambiguous and export of `my token` currently the best of
the three.

