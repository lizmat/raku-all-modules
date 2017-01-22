use Test;
use US-ASCII;

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
    upper   =>  $([~] @upper-r),
    lower   =>  $([~] @lower-r),
    digit   =>  $([~] @digit-r),
    punct   =>  q<!"#%&'()*,-./:;?@[\]_{}>,
    xdigit  =>  (@digit-r, 'A' .. 'F', 'a' .. 'f').flat.join,
    hexdig  =>  (@digit-r, 'A' .. 'F').flat.join,
    alpha   =>  (@upper-r, @lower-r).flat.join,
    alnum   =>  (@digit-r, @upper-r, @lower-r).flat.join,
    blank   =>  "\t ",
    space   =>  "\t\n\x[0B]\x[0C]\r ",
    cntrl   =>  ( chr(0) .. chr(0x0F), chr(0x7F) ).flat.join
;
%charset-str.append:
    (   graph   =>  (
            @digit-r, @upper-r, @lower-r,
            %charset-str< punct >.comb
        ).flat.sort.join
    ),
    (   print   =>  (
            @digit-r, @upper-r, @lower-r,
            %charset-str< punct >.comb,
            %charset-str< space >.comb,
        ).flat.sort.join
    ),
    (   vchar =>    (chr(0x21) .. chr(0x7E)).join   ),
;

plan 29;

# should be able to loop with interpolation but ...
# grammar g { token t { <[2]> } }; say so "2" ~~ /<g::t>/; my $rname = "t"; say so "2" ~~ /<g::($rname)>/
# see also https://docs.perl6.org/language/packages#index-entry-%3A%3A%28%29

is $latin-chars.comb(/<US-ASCII::alpha>/).join, %charset-str< alpha >,
    'alpha correct US-ASCII char subset';
is $latin-chars.comb(/<US-ASCII::upper>/).join, %charset-str< upper >,
    'upper correct US-ASCII char subset';
is $latin-chars.comb(/<US-ASCII::lower>/).join, %charset-str< lower >,
    'lower correct US-ASCII char subset';
is $latin-chars.comb(/<US-ASCII::digit>/).join, %charset-str< digit >,
    'digit correct US-ASCII char subset';
is $latin-chars.comb(/<US-ASCII::xdigit>/).join, %charset-str< xdigit >,
    'xdigit correct US-ASCII char subset';
is $latin-chars.comb(/<US-ASCII::hexdig>/).join, %charset-str< hexdig >,
    'hexdig correct US-ASCII char subset';
is $latin-chars.comb(/<US-ASCII::alnum>/).join, %charset-str< alnum >,
    'alnum correct US-ASCII char subset';
is $latin-chars.comb(/<US-ASCII::punct>/).join, %charset-str< punct >,
    'punct chars since unicode 6.1';
is $latin-chars.comb(/<US-ASCII::graph>/).join, %charset-str< graph >,
    'graph correct US-ASCII char subset';
is $latin-chars.comb(/<US-ASCII::blank>/).join, %charset-str< blank >,
    'blank correct US-ASCII char subset';
is $latin-chars.comb(/<US-ASCII::space>/).join, %charset-str< space >,
    'space correct US-ASCII char subset';
is $latin-chars.comb(/<US-ASCII::print>/).join, %charset-str< print >,
    'print correct US-ASCII char subset';
is $latin-chars.comb(/<US-ASCII::cntrl>/).join, %charset-str< cntrl >,
    'cntrl correct US-ASCII char subset';
is $latin-chars.comb(/<US-ASCII::vchar>/).join, %charset-str< vchar >,
    'vchar correct US-ASCII char subset';

grammar ascii-by-count does US-ASCII-UC {
    token alpha-c   { ^ <-ALPHA>*
        [ <ALPHA> <-ALPHA>* ]   **  { %charset-str< alpha >.chars }
    $ }
    token upper-c   { ^ <-UPPER>*
        [ <UPPER> <-UPPER>* ]   **  { %charset-str< upper >.chars }
    $ }
    token lower-c   { ^ <-LOWER>*
        [ <LOWER> <-LOWER>* ]   **  { %charset-str< lower >.chars }
    $ }
    token digit-c   { ^ <-DIGIT>*
        [ <DIGIT> <-DIGIT>* ]   **  { %charset-str< digit >.chars }
    $ }
    token xdigit-c  { ^ <-XDIGIT>*
        [ <XDIGIT> <-XDIGIT>* ] **  { %charset-str< xdigit >.chars }
    $ }
    token hexdig-c  { ^ <-HEXDIG>*
        [ <HEXDIG> <-HEXDIG>* ] **  { %charset-str< hexdig >.chars }
    $ }
    token alnum-c   { ^ <-ALNUM>*
        [ <ALNUM> <-ALNUM>* ]   **  { %charset-str< alnum >.chars }
    $ }
    token punct-c   { ^ <-PUNCT>*
        [ <PUNCT> <-PUNCT>* ]   **  { %charset-str< punct >.chars }
    $ }
    token graph-c   { ^ <-GRAPH>*
        [ <GRAPH> <-GRAPH>* ]   **  { %charset-str< graph >.chars }
    $ }
    token blank-c   { ^ <-BLANK>*
        [ <BLANK> <-BLANK>* ]   **  { %charset-str< blank >.chars }
    $ }
    token space-c   { ^ <-SPACE>*
        [ <SPACE> <-SPACE>* ]   **  { %charset-str< space >.chars }
    $ }
    token print-c   { ^ <-PRINT>*
        [ <PRINT> <-PRINT>* ]   **  { %charset-str< print >.chars }
    $ }
    token cntrl-c   { ^ <-CNTRL>*
        [ <CNTRL> <-CNTRL>* ]   **  { %charset-str< cntrl >.chars }
    $ }
    token vchar-c   { ^ <-VCHAR>*
        [ <VCHAR> <-VCHAR>* ]   **  { %charset-str< vchar >.chars }
    $ }

    token abnf-named { <+HTAB +DQUOTE> }

    token abnf-named-c { ^ <- abnf-named>*
        [ <abnf-named> <- abnf-named>* ] ** 2
    $ }
}

subtest {
    ok $latin-chars ~~ /<ascii-by-count::alpha-c>/,
        'ALPHA subset has right size';
    ok %charset-str< alpha > ~~ /<ascii-by-count::alpha-c>/,
        'ALPHA subset has right elements';
}, 'ALPHA char class';

subtest {
    ok $latin-chars ~~ /<ascii-by-count::upper-c>/,
        'UPPER subset has right size';
    ok %charset-str< upper > ~~ /<ascii-by-count::upper-c>/,
        'UPPER subset has right elements';
}, 'UPPER char class';

subtest {
    ok $latin-chars ~~ /<ascii-by-count::lower-c>/,
        'LOWER subset has right size';
    ok %charset-str< lower > ~~ /<ascii-by-count::lower-c>/,
        'LOWER subset has right elements';
}, 'LOWER char class';

subtest {
    ok $latin-chars ~~ /<ascii-by-count::digit-c>/,
        'DIGIT subset has right size';
    ok %charset-str< digit > ~~ /<ascii-by-count::digit-c>/,
        'DIGIT subset has right elements';
}, 'DIGIT char class';

subtest {
    ok $latin-chars ~~ /<ascii-by-count::xdigit-c>/,
        'XDIGIT subset has right size';
    ok %charset-str< xdigit > ~~ /<ascii-by-count::xdigit-c>/,
        'XDIGIT subset has right elements';
}, 'XDIGIT char class';

subtest {
    ok $latin-chars ~~ /<ascii-by-count::hexdig-c>/,
        'HEXDIG subset has right size';
    ok %charset-str< hexdig > ~~ /<ascii-by-count::hexdig-c>/,
        'HEXDIG subset has right elements';
}, 'HEXDIG char class';

subtest {
    ok $latin-chars ~~ /<ascii-by-count::alnum-c>/,
        'ALNUM subset has right size';
    ok %charset-str< alnum > ~~ /<ascii-by-count::alnum-c>/,
        'ALNUM subset has right elements';
}, 'ALNUM char class';

subtest {
    ok $latin-chars ~~ /<ascii-by-count::punct-c>/,
        'PUNCT subset has right size';
    ok %charset-str< punct > ~~ /<ascii-by-count::punct-c>/,
        'PUNCT subset has right elements';
}, 'PUNCT char class';

subtest {
    ok $latin-chars ~~ /<ascii-by-count::graph-c>/,
        'GRAPH subset has right size';
    ok %charset-str< graph > ~~ /<ascii-by-count::graph-c>/,
        'GRAPH subset has right elements';
}, 'GRAPH char class';

subtest {
    ok $latin-chars ~~ /<ascii-by-count::blank-c>/,
        'BLANK subset has right size';
    ok %charset-str< blank > ~~ /<ascii-by-count::blank-c>/,
        'BLANK subset has right elements';
}, 'BLANK char class';

subtest {
    ok $latin-chars ~~ /<ascii-by-count::space-c>/,
        'SPACE subset has right size';
    ok %charset-str< space > ~~ /<ascii-by-count::space-c>/,
        'SPACE subset has right elements';
}, 'SPACE char class';

subtest {
    ok $latin-chars ~~ /<ascii-by-count::print-c>/,
        'PRINT subset has right size';
    ok %charset-str< print > ~~ /<ascii-by-count::print-c>/,
        'PRINT subset has right elements';
}, 'PRINT char class';

subtest {
    ok $latin-chars ~~ /<ascii-by-count::cntrl-c>/,
        'CNTRL subset has right size';
    ok %charset-str< cntrl > ~~ /<ascii-by-count::cntrl-c>/,
        'CNTRL subset has right elements';
}, 'CNTRL char class';

subtest {
    ok $latin-chars ~~ /<ascii-by-count::vchar-c>/,
        'VCHAR subset has right size';
    ok %charset-str< vchar > ~~ /<ascii-by-count::vchar-c>/,
        'CNTRL subset has right elements';
}, 'CNTRL char class';

subtest {
    ok $latin-chars ~~ /<ascii-by-count::abnf-named-c>/,
        'ABNF named characters match has right size';
    ok "\t\"" ~~ /<ascii-by-count::abnf-named-c>/,
        'ABNF named characters has right elements';
}, 'some ABNF named characters';
