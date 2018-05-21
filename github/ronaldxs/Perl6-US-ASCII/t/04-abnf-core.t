use Test;
use US-ASCII::ABNF::Core :ALL;

# missing CRLF


# much testing copied from roast charsets.t
# https://github.com/perl6/roast/blob/master/S05-mass/charsets.t

# latin-chars are characters from first two Unicode code blocks
# which are "Basic Latin" and "Latin-1 Supplement"
my $latin-chars = [~] chr(0)..chr(0xFF);

my @upper-r = 'A' .. 'Z';
my @lower-r = 'a' .. 'z';
my @digit-r = '0' .. '9';

# note - the characters appear in "sort" order in each string
my %charset-str = 
    ALPHA   =>  (@upper-r, @lower-r).flat.join,
    BIT     =>  "01",
    CTL     =>  ( chr(0) .. chr(0x1F), chr(0x7F) ).flat.join,
    DIGIT   =>  $([~] @digit-r),
    HEXDIG  =>  (@digit-r, 'A' .. 'F').flat.join,
    VCHAR   =>  (chr(0x21) .. chr(0x7E)).join,
    WSP     =>  "\t ",
;

plan 41;

# should be able to loop with interpolation but ...
# grammar g { token t { <[2]> } }; say so "2" ~~ /<g::t>/; my $rname = "t"; say so "2" ~~ /<g::($rname)>/
# see also https://docs.perl6.org/language/packages#index-entry-%3A%3A%28%29

grammar ABNF-Core is US-ASCII::ABNF::Core {};

sub test-role-and-import(
    Regex $role-regex, Regex $import-regex,
    Str $comb-result-str, Str $test-desc
) {
    is $latin-chars.comb($role-regex).join, $comb-result-str,
        "ABNF Core $test-desc";
    is $latin-chars.comb($import-regex).join, $comb-result-str,
        "imported ABNF::Core $test-desc";
}

test-role-and-import /<ABNF-Core::ALPHA>/, /<ALPHA>/, %charset-str< ALPHA >,
    'ALPHA correct char subset';
test-role-and-import /<ABNF-Core::BIT>/, /<BIT>/, %charset-str< BIT >,
    'BIT correct char subset';

is $latin-chars.comb(/<ABNF-Core::CHAR>/).join, $([~] "\x[01]".."\x[7F]"),
    'ABNF Core CHAR matches rfc definition of %x01-7F';
is $latin-chars.comb(/<CHAR>/).join, $([~] "\x[01]".."\x[7F]"),
    'imported ABNF::Core CHAR matches rfc definition of %x01-7F';

test-role-and-import /<ABNF-Core::CR>/, /<CR>/, "\c[CR]",
    'CR exactly matches correct char';

ok "\c[CR]\c[LF]" ~~ /<ABNF-Core::CRLF>/, 'ABNF Core CRLF';
ok "\c[CR]\c[LF]" ~~ /<CRLF>/, 'imported ABNF::Core CRLF';
nok "\r" ~~ /<ABNF-Core::CRLF>/, 'ABNF Core CRLF not same as \r';
nok "\r" ~~ /<CRLF>/, 'imported ABNF Core::CRLF not same as \r';

test-role-and-import /<ABNF-Core::CTL>/, /<CTL>/, %charset-str< CTL >,
    'CTL correct char subset';
test-role-and-import /<ABNF-Core::DIGIT>/, /<DIGIT>/, %charset-str< DIGIT >,
    'DIGIT correct char subset';
test-role-and-import /<ABNF-Core::DQUOTE>/, /<DQUOTE>/, '"',
    'DQUOTE exactly matches correct char';
test-role-and-import /<ABNF-Core::HEXDIG>/, /<HEXDIG>/, %charset-str< HEXDIG >,
    'HEXDIG correct char subset';
test-role-and-import /<ABNF-Core::HTAB>/, /<HTAB>/, "\t",
    'HTAB exactly matches correct char';
test-role-and-import /<ABNF-Core::LF>/, /<LF>/, "\n",
    'LF exactly matches correct char';

ok "  \t  \r\n  \t \t\c[CR]\c[LF] " ~~ /^<ABNF-Core::LWSP>$/, 'ABNF Core LWSP';
ok "  \t  \r\n  \t \t\c[CR]\c[LF] " ~~ /^<ABNF-Core::LWSP>$/,
    'import ABNF::Core LWSP';

constant one-third = "\x2153";
nok one-third ~~ /<ABNF-Core::OCTET>/,
    'ABNF Core OCTET does not match Unicode 1/3';
is $latin-chars.comb(/<ABNF-Core::OCTET>/).join, $latin-chars,
    'ABNF Core OCTET matches all code points below 0x100';
nok one-third ~~ /<OCTET>/,
    'import ABNF::Core OCTET does not match Unicode 1/3';
is $latin-chars.comb(/<ABNF-Core::OCTET>/).join, $latin-chars,
    'ABNF Core OCTET matches all code points below 0x100';
is $latin-chars.comb(/<OCTET>/).join, $latin-chars,
    'import ABNF::Core OCTET matches all code points below 0x100';

test-role-and-import /<ABNF-Core::SP>/, /<SP>/, ' ',
    'SP exactly matches correct char';
test-role-and-import /<ABNF-Core::VCHAR>/, /<VCHAR>/, %charset-str< VCHAR >,
    'VCHAR correct char subset';
test-role-and-import /<ABNF-Core::WSP>/, /<WSP>/, %charset-str< WSP >,
    'WSP correct char subset';

ok "  \t  " ~~ /^<ABNF-Core::LWSP>$/, 'LWSP just blanks';
nok "  \t  \c[CR]\c[LF]" ~~ /^<ABNF-Core::LWSP>$/, 'LWSP one line';
nok "  \c[CR] " ~~ /^<ABNF-Core::LWSP>$/, 'LWSP with just carriage return';
nok "  \c[LF] " ~~ /^<ABNF-Core::LWSP>$/, 'LWSP with just line feed';


