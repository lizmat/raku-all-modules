use v6;
unit grammar Config::TOML::Parser::Grammar;

# disposable grammar {{{

proto token gap {*}
token gap:spacer { \s }
token gap:comment { <.comment> \n }

# end disposable grammar }}}
# comment grammar {{{

token comment
{
    '#' <comment-text>
}

token comment-text
{
    \N*
}

# end comment grammar }}}
# string grammar {{{

proto token string {*}
token string:basic { <string-basic> }
token string:basic-multi { <string-basic-multiline> }
token string:literal { <string-literal> }
token string:literal-multi { <string-literal-multiline> }

# --- string basic grammar {{{

token string-basic
{
    '"' <string-basic-text>? '"'
}

token string-basic-text
{
    <string-basic-char>+
}

proto token string-basic-char {*}

token string-basic-char:common
{
    # anything but linebreaks, double-quotes, backslashes and control
    # characters (U+0000 to U+001F)
    <+[\N] -[\" \\] -[\x00..\x1F]>
}

token string-basic-char:tab
{
    \t
}

token string-basic-char:escape-sequence
{
    # backslash followed by a valid TOML escape code, or error
    \\
    [
        <escape>

        ||

        .
        {
            say "Sorry, found bad TOML escape sequence 「$/」";
            exit;
        }
    ]
}

# For convenience, some popular characters have a compact escape sequence.
#
# \b         - backspace       (U+0008)
# \t         - tab             (U+0009)
# \n         - linefeed        (U+000A)
# \f         - form feed       (U+000C)
# \r         - carriage return (U+000D)
# \"         - quote           (U+0022)
# \\         - backslash       (U+005C)
# \uXXXX     - unicode         (U+XXXX)
# \UXXXXXXXX - unicode         (U+XXXXXXXX)
proto token escape {*}
token escape:sym<b> { <sym> }
token escape:sym<t> { <sym> }
token escape:sym<n> { <sym> }
token escape:sym<f> { <sym> }
token escape:sym<r> { <sym> }
token escape:sym<quote> { \" }
token escape:sym<backslash> { \\ }
token escape:sym<u> { <sym> <hex> ** 4 }
token escape:sym<U> { <sym> <hex> ** 8 }

token hex
{
    <[0..9A..F]>
}

token string-basic-multiline
{
    <string-basic-multiline-delimiter>
    <string-basic-multiline-leading-newline>?
    <string-basic-multiline-text>?
    <string-basic-multiline-delimiter>
}

token string-basic-multiline-delimiter
{
    '"""'
}

token string-basic-multiline-leading-newline
{
    # A newline immediately following the opening delimiter will be
    # trimmed.
    \n
}

token string-basic-multiline-text
{
    <string-basic-multiline-char>+
}

proto token string-basic-multiline-char {*}

token string-basic-multiline-char:common
{
    # anything but delimiters ("""), backslashes and control characters
    # (U+0000 to U+001F)
    <-string-basic-multiline-delimiter -[\\] -[\x00..\x1F]>
}

token string-basic-multiline-char:tab
{
    \t
}

token string-basic-multiline-char:newline
{
    \n+
}

token string-basic-multiline-char:escape-sequence
{
    # backslash followed by either a valid TOML escape code or linebreak,
    # else error
    \\
    [
        [
            <escape> | $$ <ws-remover>
        ]

        ||

        .
        {
            say "Sorry, found bad TOML escape sequence 「$/」";
            exit;
        }
    ]
}

token ws-remover
{
    # For writing long strings without introducing extraneous whitespace,
    # end a line with a \. The \ will be trimmed along with all whitespace
    # (including newlines) up to the next non-whitespace character or
    # closing delimiter.
    \n+\s*
}

# --- end string basic grammar }}}
# --- string literal grammar {{{

token string-literal
{
    \' <string-literal-text>? \'
}

token string-literal-text
{
    <string-literal-char>+
}

proto token string-literal-char {*}

token string-literal-char:common
{
    # anything but linebreaks and single quotes
    # Since there is no escaping, there is no way to write a single
    # quote inside a literal string enclosed by single quotes.
    <+[\N] -[\']>
}

token string-literal-char:backslash
{
    \\
}

token string-literal-multiline
{
    <string-literal-multiline-delimiter>
    <string-literal-multiline-leading-newline>?
    <string-literal-multiline-text>?
    <string-literal-multiline-delimiter>
}

token string-literal-multiline-delimiter
{
    \'\'\'
}

token string-literal-multiline-leading-newline
{
    # A newline immediately following the opening delimiter will be
    # trimmed.
    \n
}

token string-literal-multiline-text
{
    <string-literal-multiline-char>+
}

proto token string-literal-multiline-char {*}

token string-literal-multiline-char:common
{
    # anything but delimiters (''') and backslashes
    <-string-literal-multiline-delimiter -[\\]>
}

token string-literal-multiline-char:backslash
{
    \\
}

# --- end string literal grammar }}}

# end string grammar }}}
# number grammar {{{

token number
{
    <float> | <integer>
}

token integer
{
    <plus-or-minus>? <whole-number>
}

proto token plus-or-minus {*}
token plus-or-minus:sym<+> { <sym> }
token plus-or-minus:sym<-> { <sym> }

token whole-number
{
    0

    |

    # Leading zeros are not allowed.
    <[1..9]> [ '_'? <.digits> ]?
}

token digits
{
    \d+

    |

    # For large numbers, you may use underscores to enhance
    # readability. Each underscore must be surrounded by at least
    # one digit.
    \d+ '_' <.digits>
}

token float
{
    <integer-part=.integer>
    [
        '.' <fractional-part=.digits> <exponent-part>?
        | <exponent-part>
    ]
}

token exponent-part
{
    <[Ee]> <integer-part=.integer>
}

# end number grammar }}}
# boolean grammar {{{

# Booleans are just the tokens you're used to. Always lowercase.
proto token boolean {*}
token boolean:sym<true> { <sym> }
token boolean:sym<false> { <sym> }

# end boolean grammar }}}
# datetime grammar {{{

# There are three ways to express a datetime. The first is simply by
# using the RFC 3339 spec.
#
#     date1 = 1979-05-27T07:32:00Z
#     date2 = 1979-05-27T00:32:00-07:00
#     date3 = 1979-05-27T00:32:00.999999-07:00
#
# You may omit the local offset and let the parser or host application
# decide that information. A good default is to use the host machine's
# local offset.
#
#     1979-05-27T07:32:00
#     1979-05-27T00:32:00.999999
#
# If you only care about the day, you can omit the local offset and the
# time, letting the parser or host application decide both. Good defaults
# are to use the host machine's local offset and 00:00:00.
#
#     1979-05-27

proto token date {*}

# RFC 3339 timestamp: http://tools.ietf.org/html/rfc3339
token date:date-time
{
    <date-time>
}

# RFC 3339 timestamp (omit local offset)
token date:date-time-omit-local-offset
{
    <date-time-omit-local-offset>
}

# YYYY-MM-DD
token date:full-date
{
    <full-date>
}

token date-fullyear
{
    \d ** 4
}

token date-month
{
    0 <[1..9]> | 1 <[0..2]>
}

token date-mday
{
    0 <[1..9]> | <[1..2]> \d | 3 <[0..1]>
}

token time-hour
{
    <[0..1]> \d | 2 <[0..3]>
}

token time-minute
{
    <[0..5]> \d
}

token time-second
{
    # The grammar element time-second may have the value "60" at the end
    # of months in which a leap second occurs.
    <[0..5]> \d | 60
}

token time-secfrac
{
    '.' \d+
}

token time-numoffset
{
    <plus-or-minus> <time-hour> ':' <time-minute>
}

token time-offset
{
    <[Zz]> | <time-numoffset>
}

token partial-time
{
    <time-hour> ':' <time-minute> ':' <time-second> <time-secfrac>?
}

token full-date
{
    <date-fullyear> '-' <date-month> '-' <date-mday>
}

token full-time
{
    <partial-time> <time-offset>
}

token date-time
{
    <full-date> <[Tt]> <full-time>
}

token date-time-omit-local-offset
{
    <full-date> <[Tt]> <partial-time>
}

# end datetime grammar }}}
# array grammar {{{

token array
{
    '['
    <.gap>*
    [ <array-elements> <.gap>* ','? ]?
    <.gap>*
    ']'
}

proto token array-elements {*}

token array-elements:strings
{
    <string>
    [
        <.gap>* ',' <.gap>*
        <string>
    ]*
}

token array-elements:integers
{
    <integer>
    [
        <.gap>* ',' <.gap>*
        <integer>
    ]*
}

token array-elements:floats
{
    <float>
    [
        <.gap>* ',' <.gap>*
        <float>
    ]*
}

token array-elements:booleans
{
    <boolean>
    [
        <.gap>* ',' <.gap>*
        <boolean>
    ]*
}

token array-elements:dates
{
    <date>
    [
        <.gap>* ',' <.gap>*
        <date>
    ]*
}

token array-elements:arrays
{
    <array>
    [
        <.gap>* ',' <.gap>*
        <array>
    ]*
}

token array-elements:table-inlines
{
    <table-inline>
    [
        <.gap>* ',' <.gap>*
        <table-inline>
    ]*
}

# end array grammar }}}
# table grammar {{{

token table-inline
{
    '{'
    <.gap>*
    [ <table-inline-keypairs> <.gap>* ','? ]?
    <.gap>*
    '}'
}

token table-inline-keypairs
{
    <keypair>
    [
        <.gap>* ',' <.gap>*
        <keypair>
    ]*
}

token keypair
{
    <keypair-key> \h* '=' \h* [ <keypair-value> | <table-inline> ]
}

proto token keypair-key {*}
token keypair-key:bare { <+alnum +[-]>+ }
token keypair-key:quoted { <keypair-key-string> }

# quoted keys follow the exact same rules as either basic strings or
# literal strings
proto token keypair-key-string {*}
token keypair-key-string:basic { <string-basic> }
token keypair-key-string:literal { <string-literal> }

proto token keypair-value {*}
token keypair-value:string { <string> }
token keypair-value:number { <number> }
token keypair-value:boolean { <boolean> }
token keypair-value:date { <date> }
token keypair-value:array { <array> }

# end table grammar }}}
# document grammar {{{

# blank line
token blank-line
{
    ^^ \h* $$ \n
}

# comment appearing on its own line
token comment-line
{
    ^^ \h* <.comment> $$ \n
}

# keypair appearing on its own line
token keypair-line
{
    ^^ \h* <keypair> \h* <.comment>? $$ \n
}

proto token table {*}

# standard TOML table (hash of hashes)
token table:hoh
{
    ^^ \h* <hoh-header> \h* <.comment>? $$ \n
    [ <keypair-line> | <.comment-line> | <.blank-line> ]*
}

# TOML array of tables (array of hashes)
token table:aoh
{
    ^^ \h* <aoh-header> \h* <.comment>? $$ \n
    [ <keypair-line> | <.comment-line> | <.blank-line> ]*
}

# hash of hashes header
token hoh-header
{
    '[' \h* <table-header-text> \h* ']'
}

# array of hashes header
token aoh-header
{
    '[[' \h* <table-header-text> \h* ']]'
}

token table-header-text
{
    <keypair-key> [ \h* '.' \h* <keypair-key> ]*
}

proto token segment {*}

token segment:blank-line
{
    <.blank-line>
}

token segment:comment-line
{
    <.comment-line>
}

token segment:keypair-line
{
    <keypair-line>
}

token segment:table
{
    <table>
}

token document
{
    <segment>*
}

token TOP
{
    <document>
}

# end document grammar }}}

# vim: ft=perl6 fdm=marker fdl=0
