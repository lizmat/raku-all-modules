NAME
====

US-ASCII - ASCII restricted character classes based on Perl 6 predefined classes and ABNF/RFC5234 Core.

SYNOPSIS
========

```perl6
use US-ASCII;

say so /<US-ASCII::alpha>/ for <A À 9>; # True, False, False

grammar IPv6 does US-ASCII-UC {
    token h16 { <HEXDIG> ** 1..4}
}
# False, True, True, False, False
say so IPv6.parse($_, :rule<h16>) for ('DÉÃD', 'BEEF', 'A0', 'A๐', 'a0');

grammar SQL_92 does US-ASCII-UC {
    token unsigned-integer { <DIGIT>+ }
}
# True, False
say so SQL_92.parse($_, :rule<unsigned-integer>) for ('42', '4૫');
```

```perl6
use US-ASCII :UC;

say so /<ALPHA>/ for <A À 9>; # True, False, False
```

DESCRIPTION
===========

This module provides regex character classes restricted to ASCII including the predefined character classes of Perl 6 and ABNF (RFC 5234) Core rules. The US-ASCII grammar defines most character classes in lower case for direct use without composition as in the first SYNOPSIS example. The US-ASCII-UC role defines all character classes in upper case and is intended for composition into grammars. Upper case US-ASCII tokens may be imported with the import tag `:UC`. Composition of upper case named regex/tokens does not override the predefined Perl 6 character classes and conforms better to RFC 5234 ABNF, facilitating use with grammars of other internet standards based on that RFC.

The distribution also includes an `US-ASCII::ABNF::Core` module with tokens for ABNF Core as enumerated in RFC 5234. See further details in that module's documentation. There is also an `US-ASCIIx` module which is a POSIX variant with a `:POSIX` import tag and `alpha`, `alnum` and their uppercase export versions do not include underscore, '_'.

The `US-ASCII-ABNF` role of the `US-ASCII` module extends `US-ASCII-UC` by defining all ABNF Core tokens including ones like DQUOTE that are trivially coded in Perl6 and others that are likely only to be useful for composition in grammars related to ABNF. For conformance with ABNF, `ALPHA` and `ALNUM` do not include underscore, '_' in this module.

Unlike RFC 5234, and some existing Perl 6 implementations of it, US-ASCII rules are very rarely defined by ordinal values and mostly use, hopefully clearer, Perl 6 character ranges and names. Actually you could code most of these rules/tokens easily enough yourself as demonstrated below but the modules may still help collect and organize them for reuse.

```perl6
my token DIGIT { <digit> & <:ascii> } # implemented with conjunction
```

Named Regex (token)
===================

Named Regex (token) in differing case in US-ASCII and US-ASCII-UC/(import tag :UC)
----------------------------------------------------------------------------------

Almost all are based on predefined Perl 6 character classes.

  * alpha / ALPHA

  * alpha_x / ALPHAx # alpha without '_' underscore

  * upper / UPPER

  * lower / LOWER

  * digit / DIGIT

  * xdigit / XDIGIT

  * hexdig / HEXDIG # ABNF 0..9A..F (but not a..f)

  * alnum / ALNUM

  * alnum_x / ALNUMx # alnum without '_' underscore

  * punct / PUNCT

  * graph / GRAPH

  * blank / BLANK

  * space / SPACE

  * print / PRINT

  * cntrl / CNTRL

  * vchar / VCHAR # ABNF \x[21]..\x[7E] visible (printing) chars

  * wb / WB

  * ww / WW

  * ident / IDENT

Shared by both US-ASCII and US-ASCII-UC
---------------------------------------

  * BIT ('0' or '1')

  * CHAR (Anything in US-ASCII other than NUL)

  * CRLF

Named Regex (token) in US-ASCII-ABNF/(import tag :ABNF) only useful for ABNF
----------------------------------------------------------------------------

  * CR

  * CTL

  * DQUOTE

  * HTAB

  * LF

  * SP (space)

  * LWSP (ABNF linear white space)

  * OCTET

  * WSP

<table class="pod-table">
<thead><tr>
<th>ABNF Core rule</th> <th>Perl 6 equivalent</th>
</tr></thead>
<tbody>
<tr> <td>CR</td> <td>\c[CR]</td> </tr> <tr> <td>CTL</td> <td>US-ASCII cntrl / CNTRL</td> </tr> <tr> <td>DQUOTE</td> <td>&#39;&quot;&#39;</td> </tr> <tr> <td>HTAB</td> <td>&quot;\t&quot;</td> </tr> <tr> <td>LF</td> <td>\c[LF]</td> </tr> <tr> <td>SP</td> <td>&#39; &#39;</td> </tr> <tr> <td>WSP</td> <td>US-ASCII blank / BLANK</td> </tr>
</tbody>
</table>

ABNF Core
=========

Since ABNF is defined using the ASCII character set the distribution includes an US-ASCII::ABNF::Core module defining the tokens for ABNF Core as enumerated in RFC 5234. See that module's documentation for more detail.

US-ASCIIx import tag :POSIX
---------------------------

As previously mentioned for the `US-ASCII` module `ALPHA` and `ALNUM` include the underscore ('\_') and for `US-ASCIIx` those two tokens DO NOT include underscore.

  * ALPHA

  * UPPER

  * LOWER

  * DIGIT

  * XDIGIT

  * ALNUM

  * PUNCT

  * GRAPH

  * BLANK

  * SPACE

  * PRINT

  * CNTRL

Backward compatibility break with CR, LF, SP.
---------------------------------------------

In 0.1.X releases CR, LF and SP were provided by the US-ASCII grammar. They are now treated as ABNF Core only tokens, as they can be easily enough coded in Perl 6 using equivalents noted in the table above.

LIMITATIONS
===========

Perl 6 strings treat `"\c[CR]\c[LF]"` as a single grapheme and that sequence will not match either `<CR>` or `<LF>` but will match `<CRLF>`.

The Unicode `\c[KELVIN SIGN]` at code point `\x[212A]` is normalized by Perl 6 string processing to the letter 'K' and `say so "\x[212A]" ~~ /K/ ` prints `True`. Regex tests that match the letter K, including US-ASCII tokens, may thus appear to match the Kelvin sign.

Export of tokens
================

Export of tokens and other `Regex` types is not formally documented. Regex(es) are derived from `Method` which is in turn derived from `Routine`. `Sub` is also derived from `Routine` and well documented and established as exportable including lexical `my sub`. There is a roast example of exporting an operator method in S06-operator-overloading/infix.t and also mention of method export in a Dec 12, 2009 advent blog post. Further documentation and test of export on `Method` and `Regex` types is of interest to these modules and project.

This implementation uses `my`/lexical scope to export tokens the same way a module would export a `my sub`. I looked into `our` scope and no scope specifier for the declarations and came across [roast issue #426](https://github.com/perl6/roast/issues/426), which I felt made the choice ambiguous and export of `my token` currently the best of the three.

