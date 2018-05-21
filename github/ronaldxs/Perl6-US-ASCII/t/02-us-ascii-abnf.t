use Test;
use US-ASCII;


# latin-chars are characters from first two Unicode code blocks
# which are "Basic Latin" and "Latin-1 Supplement"
my $latin-chars = [~] chr(0)..chr(0xFF);

plan 20;

is $latin-chars.comb(/<US-ASCII::BIT>/ ).join, '01', 'ABNF named characters';

ok "\c[CR]\c[LF]" ~~ /<US-ASCII::CRLF>/, 'CRLF';
nok "\r" ~~ /<US-ASCII::CRLF>/, 'CRLF not same as \r';

######################################################################
#   Some CRLF issues
######################################################################
#
# nok "\n" ~~ /<US-ASCII::CRLF>/, 'CRLF not same as \n';
{
#    use newline :crlf; # tbd ... ??? check roast S16-io/newline.t
#    ok "\n" ~~ /<Core-More::CRLF>/, 'CRLF';
}

# Tests below don't work because \c[CR]\c[LF] is single grapheme
# ok "\c[CR]\c[LF]" ~~ /<[\x[0D]]>/, 'CRLF CR';
# ok "\c[CR]\c[LF]" ~~ /<[\x[0A]]>/, 'CRLF LF';

######################################################################


grammar test-ascii-inherit does US-ASCII-ABNF {
    token abnf-named { <+LF +CR +SP +BIT +DQUOTE +HTAB> }

    token abnf-named-c { ^ <- abnf-named>*
        [ <abnf-named> <- abnf-named>* ] ** 7
    $ }
    token wsp-c { ^ <- WSP>*
        [ <WSP> <- WSP>* ] ** 2
    $ }
    token ctl-c { ^ <- CTL>*
                [ <CTL> <- CTL>* ] ** 33 # 0 .. x1F is 32 plus 0x7F = 33
    $ }
    token empty-dos-line { ^ <CRLF> $ }

    # nice to add tests for LWSP but tested for now just in 04-abnf-core.t
}

ok $latin-chars ~~ /<test-ascii-inherit::abnf-named-c>/,
    'ABNF named characters set has right size';
ok "\t\x[0A]\x[0D] \"01" ~~ /<test-ascii-inherit::abnf-named-c>/,
    'ABNF named characters set has right elements';

ok $latin-chars ~~ /<test-ascii-inherit::wsp-c>/,
    'ABNF WSP has right size';
ok "\t " ~~ /<test-ascii-inherit::wsp-c>/,
    'ABNF WSP has right elements';

constant all-ascii-ctl = ( chr(0) .. chr(0x1F), chr(0x7F) ).flat.join;
ok $latin-chars ~~ /<test-ascii-inherit::ctl-c>/,
    'ABNF CTL has right size';
ok all-ascii-ctl ~~ /<test-ascii-inherit::ctl-c>/,
    'ABNF CTL has right elements';

is-deeply
    [ ("\c[CR]\c[LF]", "a\c[CR]\c[LF]", "\c[LF]").grep:
        { /<test-ascii-inherit::empty-dos-line>/ } ],
    [ "\c[CR]\c[LF]" ],
    'CRLF using role'; 
constant one-third = "\x2153";

{
    use US-ASCII :UC;
    is $latin-chars.comb(/<BIT>/).join, '01', 'ABNF named characters';
}
{
    use US-ASCII :ABNF;

    is $latin-chars.comb(/<HTAB>/).join, "\t",
        'ABNF named char from ABNF tag';
    nok one-third ~~ /<OCTET>/, 'Unicode 1/3 0x2153 does not match octet';
    is $latin-chars.comb(/<OCTET>/).join, $latin-chars,
        'octet matches all code points below 0x100';
}

nok one-third ~~ /<test-ascii-inherit::OCTET>/,
    'Unicode 1/3 0x2153 does not match octet from role';
is $latin-chars.comb(/<test-ascii-inherit::OCTET>/).join, $latin-chars,
    'octet from role matches all code points below 0x100';

throws-like { ' ' ~~ /<SP>/ }, X::Method::NotFound,
    'only export UC on request';
throws-like { ' ' ~~ /<HTAB>/ }, X::Method::NotFound,
    'only export HTAB on request for :ABNF';

{
    use US-ASCII :ALL;

    is $latin-chars.comb(/<SP>/).join, ' ',
        'ABNF SP/space from ALL tag';
    is $latin-chars.comb(/<DQUOTE>/).join, '"',
        'ABNF DQUOTE from ALL tag';
}
