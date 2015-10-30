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
    '#' <comment_text>
}

token comment_text
{
    \N*
}

# end comment grammar }}}
# string grammar {{{

proto token string {*}
token string:basic { <string_basic> }
token string:basic_multi { <string_basic_multiline> }
token string:literal { <string_literal> }
token string:literal_multi { <string_literal_multiline> }

# --- string basic grammar {{{

token string_basic
{
    '"' <string_basic_text>? '"'
}

token string_basic_text
{
    <string_basic_char>+
}

proto token string_basic_char {*}

token string_basic_char:common
{
    # anything but linebreaks, double-quotes, backslashes and control
    # characters (U+0000 to U+001F)
    <+[\N] -[\" \\] -[\x00..\x1F]>
}

token string_basic_char:tab
{
    \t
}

token string_basic_char:escape_sequence
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

token string_basic_multiline
{
    <string_basic_multiline_delimiter>
    <string_basic_multiline_leading_newline>?
    <string_basic_multiline_text>?
    <string_basic_multiline_delimiter>
}

token string_basic_multiline_delimiter
{
    '"""'
}

token string_basic_multiline_leading_newline
{
    # A newline immediately following the opening delimiter will be
    # trimmed.
    \n
}

token string_basic_multiline_text
{
    <string_basic_multiline_char>+
}

proto token string_basic_multiline_char {*}

token string_basic_multiline_char:common
{
    # anything but delimiters ("""), backslashes and control characters
    # (U+0000 to U+001F)
    <-string_basic_multiline_delimiter -[\\] -[\x00..\x1F]>
}

token string_basic_multiline_char:tab
{
    \t
}

token string_basic_multiline_char:newline
{
    \n+
}

token string_basic_multiline_char:escape_sequence
{
    # backslash followed by either a valid TOML escape code or linebreak,
    # else error
    \\
    [
        [
            <escape> | $$ <ws_remover>
        ]

        ||

        .
        {
            say "Sorry, found bad TOML escape sequence 「$/」";
            exit;
        }
    ]
}

token ws_remover
{
    # For writing long strings without introducing extraneous whitespace,
    # end a line with a \. The \ will be trimmed along with all whitespace
    # (including newlines) up to the next non-whitespace character or
    # closing delimiter.
    \n+\s*
}

# --- end string basic grammar }}}
# --- string literal grammar {{{

token string_literal
{
    \' <string_literal_text>? \'
}

token string_literal_text
{
    <string_literal_char>+
}

proto token string_literal_char {*}

token string_literal_char:common
{
    # anything but linebreaks and single quotes
    # Since there is no escaping, there is no way to write a single
    # quote inside a literal string enclosed by single quotes.
    <+[\N] -[\']>
}

token string_literal_char:backslash
{
    \\
}

token string_literal_multiline
{
    <string_literal_multiline_delimiter>
    <string_literal_multiline_leading_newline>?
    <string_literal_multiline_text>?
    <string_literal_multiline_delimiter>
}

token string_literal_multiline_delimiter
{
    \'\'\'
}

token string_literal_multiline_leading_newline
{
    # A newline immediately following the opening delimiter will be
    # trimmed.
    \n
}

token string_literal_multiline_text
{
    <string_literal_multiline_char>+
}

proto token string_literal_multiline_char {*}

token string_literal_multiline_char:common
{
    # anything but delimiters (''') and backslashes
    <-string_literal_multiline_delimiter -[\\]>
}

token string_literal_multiline_char:backslash
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
    <plus_or_minus>? <whole_number>
}

proto token plus_or_minus {*}
token plus_or_minus:sym<+> { <sym> }
token plus_or_minus:sym<-> { <sym> }

token whole_number
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
    <integer_part=.integer>
    [
        '.' <fractional_part=.digits> <exponent_part>?
        | <exponent_part>
    ]
}

token exponent_part
{
    <[Ee]> <integer_part=.integer>
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
token date:date_time
{
    <date_time>
}

# RFC 3339 timestamp (omit local offset)
token date:date_time_omit_local_offset
{
    <date_time_omit_local_offset>
}

# YYYY-MM-DD
token date:full_date
{
    <full_date>
}

token date_fullyear
{
    \d ** 4
}

token date_month
{
    0 <[1..9]> | 1 <[0..2]>
}

token date_mday
{
    0 <[1..9]> | <[1..2]> \d | 3 <[0..1]>
}

token time_hour
{
    <[0..1]> \d | 2 <[0..3]>
}

token time_minute
{
    <[0..5]> \d
}

token time_second
{
    # The grammar element time-second may have the value "60" at the end
    # of months in which a leap second occurs.
    <[0..5]> \d | 60
}

token time_secfrac
{
    '.' \d+
}

token time_numoffset
{
    <plus_or_minus> <time_hour> ':' <time_minute>
}

token time_offset
{
    <[Zz]> | <time_numoffset>
}

token partial_time
{
    <time_hour> ':' <time_minute> ':' <time_second> <time_secfrac>?
}

token full_date
{
    <date_fullyear> '-' <date_month> '-' <date_mday>
}

token full_time
{
    <partial_time> <time_offset>
}

token date_time
{
    <full_date> <[Tt]> <full_time>
}

token date_time_omit_local_offset
{
    <full_date> <[Tt]> <partial_time>
}

# end datetime grammar }}}
# array grammar {{{

token array
{
    '['
    <.gap>*
    [ <array_elements> <.gap>* ','? ]?
    <.gap>*
    ']'
}

proto token array_elements {*}

token array_elements:strings
{
    <string>
    [
        <.gap>* ',' <.gap>*
        <string>
    ]*
}

token array_elements:integers
{
    <integer>
    [
        <.gap>* ',' <.gap>*
        <integer>
    ]*
}

token array_elements:floats
{
    <float>
    [
        <.gap>* ',' <.gap>*
        <float>
    ]*
}

token array_elements:booleans
{
    <boolean>
    [
        <.gap>* ',' <.gap>*
        <boolean>
    ]*
}

token array_elements:dates
{
    <date>
    [
        <.gap>* ',' <.gap>*
        <date>
    ]*
}

token array_elements:arrays
{
    <array>
    [
        <.gap>* ',' <.gap>*
        <array>
    ]*
}

token array_elements:table_inlines
{
    <table_inline>
    [
        <.gap>* ',' <.gap>*
        <table_inline>
    ]*
}

# end array grammar }}}
# table grammar {{{

token table_inline
{
    '{'
    <.gap>*
    [ <table_inline_keypairs> <.gap>* ','? ]?
    <.gap>*
    '}'
}

token table_inline_keypairs
{
    <keypair>
    [
        <.gap>* ',' <.gap>*
        <keypair>
    ]*
}

token keypair
{
    <keypair_key> \h* '=' \h* [ <keypair_value> | <table_inline> ]
}

proto token keypair_key {*}

token keypair_key:bare
{
    <+alnum +[-]>+
}

token keypair_key:quoted
{
    <keypair_key_string_basic>
}

# quoted keys must contain chars inside double quotes
token keypair_key_string_basic
{
    '"' <string_basic_text> '"'
}

proto token keypair_value {*}
token keypair_value:string { <string> }
token keypair_value:number { <number> }
token keypair_value:boolean { <boolean> }
token keypair_value:date { <date> }
token keypair_value:array { <array> }

# end table grammar }}}
# document grammar {{{

# blank line
token blank_line
{
    ^^ \h* $$ \n
}

# comment appearing on its own line
token comment_line
{
    ^^ \h* <.comment> $$ \n
}

# keypair appearing on its own line
token keypair_line
{
    ^^ \h* <keypair> \h* <.comment>? $$ \n
}

proto token table {*}

# standard TOML table (hash of hashes)
token table:hoh
{
    ^^ \h* <hoh_header> \h* <.comment>? $$ \n
    [ <keypair_line> | <.comment_line> | <.blank_line> ]*
}

# TOML array of tables (array of hashes)
token table:aoh
{
    ^^ \h* <aoh_header> \h* <.comment>? $$ \n
    [ <keypair_line> | <.comment_line> | <.blank_line> ]*
}

# hash of hashes header
token hoh_header
{
    '[' \h* <table_header_text> \h* ']'
}

# array of hashes header
token aoh_header
{
    '[[' \h* <table_header_text> \h* ']]'
}

token table_header_text
{
    <keypair_key> [ \h* '.' \h* <keypair_key> ]*
}

proto token segment {*}

token segment:blank_line
{
    <.blank_line>
}

token segment:comment_line
{
    <.comment_line>
}

token segment:keypair_line
{
    <keypair_line>
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
