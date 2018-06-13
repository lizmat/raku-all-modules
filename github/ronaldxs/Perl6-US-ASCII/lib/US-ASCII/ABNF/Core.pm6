use v6.c;

=begin pod

=head1 NAME

US-ASCII::ABNF::Core - tokens for ABNF Core rules from RFC 5234

=head1 SYNOPSIS

=begin code :lang<perl6>
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
=end code

=begin code :lang<perl6>
use US-ASCII::ABNF::Core :ALL;

say so 'DÉÃD' ~~ /^<ALPHA>*$/;  # False
say so 'BEEF' ~~ /^<ALPHA>*$/;  # True
=end code

=head1 DESCRIPTION

Provides ABNF Core tokens, as specified in RFC 5234, for composition
into grammar by inheritance or from role or import for direct use
in regexes and parsing.

=head1 Tokens

=item ALPHA
=item BIT
=item CHAR
=item CR
=item CRLF
=item CTL
=item DIGIT
=item DQUOTE
=item HEXDIG
=item HTAB
=item LF
=item LWSP
=item OCTET
=item SP
=item VCHAR
=item WSP

=head1 LIMITATIONS

Perl 6 strings treat C<"\c[CR]\c[LF]"> as a single grapheme and that
sequence will not match either C< <CR>> or C< <LF>> but will match
C< <CRLF>>.

The Unicode C<\c[KELVIN SIGN]> at code point C<\x[212A]> is normalized
by Perl 6 string processing to the letter 'K' and
C< say so "\x[212A]" ~~ /K/ > prints C<True>.  Regex tests that match
the letter K, including US-ASCII::ABNF::Core tokens, may thus appear
to match the Kelvin sign.

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


use US-ASCII::ABNF::Core::Common;
use US-ASCII::ABNF::Core::P6Common;
use US-ASCII::ABNF::Core::Only;
use US-ASCII::ABNF::Core::More;

role US-ASCII::ABNF::Core-r:ver<0.1.2>:auth<R Schmidt (ronaldxs@software-path.com)>
    does US-ASCII::ABNF::Core::Common
    does US-ASCII::ABNF::Core::Only
    does US-ASCII::ABNF::Core::More
{
    token ALPHA     { <[A..Za..z]>   }
    token DIGIT     { <.US-ASCII::ABNF::Core::P6Common-g::digit>   }
    token HEXDIG    { <.US-ASCII::ABNF::Core::P6Common-g::hexdig>  }
    token VCHAR     { <.US-ASCII::ABNF::Core::P6Common-g::vchar>   }
}

grammar US-ASCII::ABNF::Core:ver<0.1.2>:auth<R Schmidt (ronaldxs@software-path.com)>
    does US-ASCII::ABNF::Core-r
{
    my    token     ALPHA     is export(:common)
      { <.US-ASCII::ABNF::Core::ALPHA> }
    my    token     BIT       is export(:common)
      { <.US-ASCII::ABNF::Core::BIT> }
    my    token     CHAR      is export(:ALL)
      { <.US-ASCII::ABNF::Core::CHAR> }
    my    token     CR        is export(:ALL)
      { <.US-ASCII::ABNF::Core::CR> }
    my    token     CRLF      is export(:common)
      { <.US-ASCII::ABNF::Core::CRLF> }
    my    token     CTL       is export(:common)
      { <.US-ASCII::ABNF::Core::CTL> }
    my    token     DIGIT     is export(:common)
      { <.US-ASCII::ABNF::Core::DIGIT> }
    my    token     DQUOTE    is export(:ALL)
      { <.US-ASCII::ABNF::Core::DQUOTE> }
    my    token     HEXDIG    is export(:common)
      { <.US-ASCII::ABNF::Core::HEXDIG> }
    my    token     HTAB      is export(:ALL)
      { <.US-ASCII::ABNF::Core::HTAB> }
    my    token     LF        is export(:ALL)
      { <.US-ASCII::ABNF::Core::LF> }
    my    token     LWSP      is export(:ALL)
      { <.US-ASCII::ABNF::Core::LWSP> }
    my    token     OCTET     is export(:ALL)
      { <.US-ASCII::ABNF::Core::OCTET> }
    my    token     SP        is export(:ALL)
      { <.US-ASCII::ABNF::Core::SP> }
    my    token     VCHAR     is export(:common)
      { <.US-ASCII::ABNF::Core::VCHAR> }
    my    token     WSP       is export(:common)
      { <.US-ASCII::ABNF::Core::WSP> }
}
