# NAME
US-ASCII - ASCII restricted character classes based on Perl 6 predefined classes and ABNF/RFC5234 Core.

# SYNOPSIS

```Perl6
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
say so SQL_92.parse($_, :rule<unsigned-integer>) for ('42', '4２');
```

```Perl6
use US-ASCII :UC;

say so /<ALPHA>/ for <A À 9>; # True, False, False
```

# DESCRIPTION

This module provides regex character classes restricted to ASCII including
the predefined character classes of Perl 6 and some ABNF (RFC 5234) Core
rules. The module defines two sets of named regexes to avoid readability
issues with long upper case names.  The US-ASCII grammar defines most
character classes in lower case for direct use without composition as in the
first SYNOPSIS example. The US-ASCII-UC role defines all character classes
in upper case and is intended for composition into grammars.  Upper case
US-ASCII tokens may be imported with the import tag `:UC`.  Composition of
upper case named regex/tokens does not override the predefined Perl 6
character classes and conforms better to RFC 5234 ABNF, facilitating use
with grammars of other internet standards based on that RFC.  Unlike RFC
5234, and some existing Perl 6 implementations of it, US-ASCII rules are
very rarely defined by ordinal values and mostly use, hopefully clearer,
Perl 6 character ranges and names.

# Named Regex (token)

## Shared by both US-ASCII and US-ASCII-UC

* LF
* CR
* SP (space)
* BIT ('0' or '1')
* CHAR (Anything in US-ASCII other than NUL)

## Named Regex (token) in differing case in US-ASCII and US-ASCII-UC/(import tag :UC)

Almost all are based on predefined Perl 6 character classes.

* alpha / ALPHA
* upper / UPPER
* lower / LOWER
* digit / DIGIT
* xdigit / XDIGIT
* hexdig / HEXDIG # ABNF 0..9A..F (but not a..f)
* alnum / ALNUM
* punct / PUNCT
* graph / GRAPH
* blank / BLANK
* space / SPACE
* print / PRINT
* cntrl / CNTRL
* vchar / VCHAR # ABNF \x[21]..\x[7E] visible (printing) chars
* wb / WB
* ww / WW

## Named Regex (token) in US-ASCII-UC/(import tag :UC) only useful for ABNF

* HTAB
* DQUOTE

# To do

There are a few more Perl 6 predefined classes and ABNF rules
that could be added.
