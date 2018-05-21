use US-ASCII::ABNF::Core::Common;
use US-ASCII::ABNF::Core::P6Common;
use US-ASCII::ABNF::Core::Only;
use US-ASCII::ABNF::Core::More;

grammar US-ASCII:ver<0.6.2>:auth<R Schmidt (ronaldxs@software-path.com)>
    does US-ASCII::ABNF::Core::Common
    does US-ASCII::ABNF::Core::P6Common
{
    token upper     { <[A..Z]> }
    token lower     { <[a..z]> }
    token xdigit    { <[0..9A..Fa..f]> }
    token alnum     { <[0..9A..Za..z]> }
    # see RT #130527 for why we might need _punct
    token _punct    { <[\-!"#%&'()*,./:;?@[\\\]_{}]> }
    token punct     { <+_punct> }
    token graph     { <+_punct +[0..9A..Za..z]> }
    token space-cc  { <[\t\c[VT]\c[FF]\c[LF]\c[CR]\ ]> }
    token space     { "\c[CR]\c[LF]" | <+space-cc> }
    token print-cc  { <+_punct +space-cc +[0..9A..Za..z]> }
    token print     { "\c[CR]\c[LF]" | <+print-cc> }

    token wb        { <?after <US-ASCII::alnum>><!US-ASCII::alnum>  |
                      <!after <US-ASCII::alnum>><?US-ASCII::alnum>
                    }
    token ww        { <?after <US-ASCII::alnum>><?US-ASCII::alnum>  }

    constant charset = set chr(0) .. chr(127);

    # should be nicer answer than hard coding package name
    my token ALPHA    is export(:UC)    { <.US-ASCII::alpha>     }
    my token UPPER    is export(:UC)    { <.US-ASCII::upper>     }
    my token LOWER    is export(:UC)    { <.US-ASCII::lower>     }
    my token DIGIT    is export(:UC)    { <.US-ASCII::digit>     }
    my token XDIGIT   is export(:UC)    { <.US-ASCII::xdigit>    }
    my token HEXDIG   is export(:UC)    { <.US-ASCII::hexdig>    }
    my token ALNUM    is export(:UC)    { <.US-ASCII::alnum>     }
    my token PUNCT    is export(:UC)    { <.US-ASCII::punct>     }
    my token GRAPH    is export(:UC)    { <.US-ASCII::graph>     }
    my token BLANK    is export(:UC)    { <.US-ASCII::blank>     }
    my token SPACE    is export(:UC)    { <.US-ASCII::space>     }
    my token PRINT    is export(:UC)    { <.US-ASCII::print>     }
    my token CNTRL    is export(:UC)    { <.US-ASCII::cntrl>     }
    my token VCHAR    is export(:UC)    { <.US-ASCII::vchar>     }
    my token WB       is export(:UC)    { <.US-ASCII::wb>        }
    my token WW       is export(:UC)    { <.US-ASCII::ww>        }

    my token CRLF     is export(:UC)    { <.US-ASCII::CRLF>      }
    my token BIT      is export(:UC)    { <.US-ASCII::BIT>       }
    my token CHAR     is export(:UC)    { <.US-ASCII::CHAR>      }

    my grammar Core-More does US-ASCII::ABNF::Core::More {};
    my token CTL      is export(:ABNF)  { <.Core-More::CTL>  }
    my token WSP      is export(:ABNF)  { <.Core-More::WSP>  }

    my grammar Core-Only does US-ASCII::ABNF::Core::Only {};
    my token CR       is export(:ABNF)  { <.Core-Only::CR>      }
    my token DQUOTE   is export(:ABNF)  { <.Core-Only::DQUOTE>  }
    my token HTAB     is export(:ABNF)  { <.Core-Only::HTAB>    }
    my token LF       is export(:ABNF)  { <.Core-Only::LF>      }
    my token SP       is export(:ABNF)  { <.Core-Only::SP>      }
    my token OCTET    is export(:ABNF)  { <.Core-Only::OCTET>   }
}

# if you are not using inheritance then US-ASCII::alpha as above is
# easier to read than US-ASCII::ALPHA.  With the role below you can
# compose upper case names of the same regexes/tokens without overwriting
# builtin character classes.
role US-ASCII-UC:ver<0.6.2>:auth<R Schmidt (ronaldxs@software-path.com)>
    does US-ASCII::ABNF::Core::Common
{
    token ALPHA     { <.US-ASCII::alpha> }
    token UPPER     { <.US-ASCII::upper> }
    token LOWER     { <.US-ASCII::lower> }
    token DIGIT     { <.US-ASCII::digit> }
    token XDIGIT    { <.US-ASCII::xdigit> }
    token HEXDIG    { <.US-ASCII::hexdig> }
    token ALNUM     { <.US-ASCII::alnum> }
    token PUNCT     { <.US-ASCII::punct> }
    token GRAPH     { <.US-ASCII::graph> }
    token BLANK     { <.US-ASCII::blank> }
    token SPACE     { <.US-ASCII::space> }
    token PRINT     { <.US-ASCII::print> }
    token CNTRL     { <.US-ASCII::cntrl> }
    token VCHAR     { <.US-ASCII::vchar> }

    token WB        { <.US-ASCII::wb> }
    token WW        { <.US-ASCII::ww> }

    # invoke with autopun as US-ASCII-UC.charset
    method charset { US-ASCII::charset }
}

role US-ASCII-ABNF:ver<0.6.2>:auth<R Schmidt (ronaldxs@software-path.com)>
    does US-ASCII-UC
    does US-ASCII::ABNF::Core::Only
    does US-ASCII::ABNF::Core::More
{};

=begin pod

=head1 NAME

US-ASCII - ASCII restricted character classes based on Perl 6 predefined classes and ABNF/RFC5234 Core.

=head1 SYNOPSIS

=begin code :lang<perl6>

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
=end code

=begin code :lang<perl6>
use US-ASCII :UC;

say so /<ALPHA>/ for <A À 9>; # True, False, False
=end code

=head1 DESCRIPTION

This module provides regex character classes restricted to ASCII including the
predefined character classes of Perl 6 and ABNF (RFC 5234) Core rules. The
US-ASCII grammar defines most character classes in lower case for direct use
without composition as in the first SYNOPSIS example. The US-ASCII-UC role
defines all character classes in upper case and is intended for composition
into grammars.  Upper case US-ASCII tokens may be imported with the import tag
C<:UC>.  Composition of upper case named regex/tokens does not override the
predefined Perl 6 character classes and conforms better to RFC 5234 ABNF,
facilitating use with grammars of other internet standards based on that RFC.
The US-ASCII-ABNF role extends US-ASCII-UC by defining all ABNF Core tokens
including ones like DQUOTE that are trivially coded in Perl6 and others that
are likely only to be useful for composition in grammars related to ABNF.
Unlike RFC 5234, and some existing Perl 6 implementations of it, US-ASCII rules
are very rarely defined by ordinal values and mostly use, hopefully clearer,
Perl 6 character ranges and names.

=head1 Named Regex (token)

=head2 Named Regex (token) in differing case in US-ASCII and US-ASCII-UC/(import tag :UC)

Almost all are based on predefined Perl 6 character classes.

=item alpha / ALPHA
=item upper / UPPER
=item lower / LOWER
=item digit / DIGIT
=item xdigit / XDIGIT
=item hexdig / HEXDIG # ABNF 0..9A..F (but not a..f)
=item alnum / ALNUM
=item punct / PUNCT
=item graph / GRAPH
=item blank / BLANK
=item space / SPACE
=item print / PRINT
=item cntrl / CNTRL
=item vchar / VCHAR # ABNF \x[21]..\x[7E] visible (printing) chars
=item wb / WB
=item ww / WW

=head2 Shared by both US-ASCII and US-ASCII-UC

=item BIT ('0' or '1')
=item CHAR (Anything in US-ASCII other than NUL)
=item CRLF

=head2 Named Regex (token) in US-ASCII-ABNF/(import tag :ABNF) only useful for ABNF

=item CR
=item CTL
=item DQUOTE
=item HTAB
=item LF
=item SP (space)
=item LWSP (ABNF linear white space)
=item OCTET
=item WSP

=begin table
ABNF Core rule | Perl 6 equivalent
=========================================
CR      | \c[CR]
CTL     | US-ASCII cntrl / CNTRL
DQUOTE  | '"'
HTAB    | "\t"
LF      | \c[LF]
SP      | ' '
WSP     | US-ASCII blank / BLANK
=end table

=head1 ABNF Core

Since ABNF is defined using the ASCII character set the distribution includes
an US-ASCII::ABNF::Core module defining the tokens for ABNF Core as enumerated
in RFC 5234.  See that module's documentation for more detail.

=head2 Backward compatibility break with CR, LF, SP.

In 0.1.X releases CR, LF and SP were provided by the US-ASCII grammar.  They
are now treated as ABNF Core only tokens, as they can be easily enough coded
in Perl 6 using equivalents noted in the table above.

=head1 LIMITATIONS

Perl 6 strings treat C<"\c[CR]\c[LF]"> as a single grapheme and that sequence
will not match either C< <CR>> or C< <LF>> but will match C< <CRLF>>.

The Unicode C<\c[KELVIN SIGN]> at code point C<\x[212A]> is normalized by
Perl 6 string processing to the letter 'K' and C< say so "\x[212A]" ~~ /K/ >
prints C<True>.  Regex tests that match the letter K, including US-ASCII
tokens, may thus appear to match the Kelvin sign.

=head1 Export of tokens

Export of tokens and other C<Regex> types is not formally documented.
Regex(es) are derived from C<Method> which is in turn derived from
C<Routine>.  C<Sub> is also derived from C<Routine> and well
documented and established as exportable including lexical
C<my sub>.  There is a roast example of exporting an operator
method in S06-operator-overloading/infix.t and also mention of
method export in a Dec 12, 2009 advent blog post.  Further
documentation and test of export on C<Method> and C<Regex> types is
of interest to these modules and project.

This implementation uses C<my>/lexical scope to export tokens the
same way a module would export a C<my sub>.  I looked into C<our>
scope and no scope specifier for the declarations and came across
L<roast issue #426|https://github.com/perl6/roast/issues/426>,
which I felt made the choice ambiguous and export of C<my token>
currently the best of the three.

=end pod
