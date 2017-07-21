use Test;
use US-ASCII;


# latin-chars are characters from first two Unicode code blocks
# which are "Basic Latin" and "Latin-1 Supplement"
my $latin-chars = [~] chr(0)..chr(0xFF);

plan 5;

is $latin-chars.comb( /
    <US-ASCII::LF>      ||
    <US-ASCII::CR>      ||
    <US-ASCII::SP>      ||
    <US-ASCII::BIT>
/ ).join, "\x[0A]\x[0D] 01", 'ABNF named characters';

# ok "\c[CR]\c[LF]" ~~ /<US-ASCII::crlf>/, 'CRLF';

# tricky / having problems
# ok "\c[CR]\c[LF]" ~~ /<US-ASCII::CR>/, 'CRLF';

grammar test-ascii-inherit does US-ASCII-UC {
    token abnf-named { <+LF +CR +SP +BIT> }

    token abnf-named-c { ^ <- abnf-named>*
        [ <abnf-named> <- abnf-named>* ] ** 5
    $ }
    token empty-dos-line { ^ <CRLF> $ }
}

#say $latin-chars.comb( /<ascii-by-count::abnf-named>/ ).map: {.ord};
ok $latin-chars ~~ /<test-ascii-inherit::abnf-named-c>/,
    'ABNF named characters set has right size';
ok "\x[0A]\x[0D] 01" ~~ /<test-ascii-inherit::abnf-named-c>/,
    'ABNF named characters set has right elements';

# tricky /having problems
# is-deeply
#    [ ("\c[CR]\c[LF]", "a\c[CR]\c[LF]", "\c[LF]").grep:
#        { /<test-ascii-inherit::empty-dos-line>/ } ],
#    [ "\c[CR]\c[LF]" ],

{
    use US-ASCII :UC;
    is $latin-chars.comb( /
        <LF>      ||
        <CR>      ||
        <SP>      ||
        <BIT>     ||
        <HTAB>    ||
        <DQUOTE>
    / ).join, "\x[09]\x[0A]\x[0D] \"01", 'ABNF named characters';
}

throws-like { ' ' ~~ /<SP>/ }, X::Method::NotFound,
    'only export UC on request';

