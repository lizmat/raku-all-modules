use v6;
unit grammar TXN::Parser::Grammar;

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
    # backslash followed by a valid (TOML) escape code, or error
    \\
    [
        <escape>

        ||

        .
        {
            say "Sorry, found bad string escape sequence 「$/」";
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
    # backslash followed by either a valid (TOML) escape code or
    # linebreak, else error
    \\
    [
        [
            <escape> | $$ <ws_remover>
        ]

        ||

        .
        {
            say "Sorry, found bad string escape sequence 「$/」";
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

proto token plus_or_minus {*}
token plus_or_minus:sym<+> { <sym> }
token plus_or_minus:sym<-> { <sym> }

token integer
{
    <plus_or_minus>? <integer_unsigned>
}

token integer_unsigned
{
    <whole_number>
}

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
    <plus_or_minus>? <float_unsigned>
}

token float_unsigned
{
    <integer_part=.integer_unsigned> '.' <fractional_part=.digits>
}

# end number grammar }}}
# datetime grammar {{{

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
# variable name grammar {{{

proto token var_name {*}

token var_name:bare
{
    <+alnum +[-]>+
}

# only double quoted variable names are allowed
token var_name:quoted
{
    <var_name_string_basic>
}

# quoted variable names must contain chars inside double quotes
token var_name_string_basic
{
    '"' <string_basic_text> '"'
}

token var_name_string_literal
{
    \' <string_literal_text> \'
}

# end variable grammar }}}
# reserved words grammar {{{

my Str @reserved_words = qw<assets base-costing base-currency>;

token reserved
{
    :i @reserved_words
}

# end reserved words grammar }}}
# header grammar {{{

regex header
{
    ^^ \h* <date> <.gap>+ [ <metainfo> <.gap>+ ]?
    [ <description> <.gap>+ [ <metainfo> <.gap>+ ]? ]?
}

token description
{
    <string>
}

token metainfo
{
    <meta> [ <.gap>+ <meta> ]*
}

proto token meta {*}
token meta:important { <important> }
token meta:tag { <tag> }

token important
{
    <exclamation_mark>+
}

token exclamation_mark
{
    '!'
}

token tag
{
    '@' <var_name>
}

# end header grammar }}}
# posting grammar {{{

token postings
{
    <posting_line>+
}

proto token posting_line {*}

token posting_line:comment
{
    <.comment_line>
}

token posting_line:content
{
    ^^ \h* <posting> \h* <.comment>? $$ \n
}

token posting
{
    <account> \h+ <amount>
}

# --- posting account grammar {{{

token account
{
    # silo and entity are required, subaccounts are optional
    <silo> <account_delimiter> <entity=.var_name>
    [ <account_delimiter> <account_sub=.acct_name> ]?
}

proto token silo {*}

token silo:assets
{
    :i asset[s]?
}

token silo:expenses
{
    :i expense[s]?
}

token silo:income
{
    :i income | revenue[s]?
}

token silo:liabilities
{
    :i liabilit[y|ies]
}

token silo:equity
{
    :i equit[y|ies]
}

# accounts can be separated by a colon (:) or period (.)
proto token account_delimiter {*}
token account_delimiter:sym<:> { <sym> }
token account_delimiter:sym<.> { <sym> }

token acct_name
{
    <var_name> [ <account_delimiter> <var_name> ]*
}

# --- end posting account grammar }}}
# --- posting amount grammar {{{

token amount
{
    # -$100.00 USD
    <plus_or_minus>? <asset_symbol>? <asset_quantity> \h+ <asset_code>
        [\h+ <exchange_rate>]?

    |

    # USD -$100.00
    <asset_code> \h+ <plus_or_minus>? <asset_symbol>? <asset_quantity>
        [\h+ <exchange_rate>]?
}

proto token asset_code {*}

token asset_code:bare
{
    <:Letter>+
}

token asset_code:quoted
{
    <var_name_string_basic>
}

# e.g. http://www.xe.com/symbols.php
token asset_symbol
{
    # any char excluding digits, plus signs, whitespace or unicode
    # punctuation less periods and slashes (some currencies use these)
    #
    # unicode punctuation is any character from the Unicode General
    # Category "Punctuation":
    # https://www.fileformat.info/info/unicode/category/index.htm
    <+[\D] -[+] -[\s] -punct +[./]>+
}

proto token asset_quantity {*}
token asset_quantity:float { <float_unsigned> }
token asset_quantity:integer { <integer_unsigned> }

token exchange_rate
{
    '@' \h+ <xe>
}

# negative xe not allowed
token xe
{
    # @ $830.024 USD
    <asset_symbol>? <asset_quantity> \h+ <asset_code>

    |

    # @ USD $830.024
    <asset_code> \h+ <asset_symbol>? <asset_quantity>
}

# --- end posting amount grammar }}}

# end posting grammar }}}
# include grammar {{{

token include_line
{
    ^^ \h* <include> \h* <.comment>? $$ \n
}

token include
{
    include \h+ <filename>
}

proto token filename {*}
token filename:basic { <var_name_string_basic> }
token filename:literal { <var_name_string_literal> }

# end include grammar }}}
# extends grammar {{{

token extends_line
{
    ^^ \h* <extends> \h* <.comment>? $$ \n
}

token extends
{
    extends \h+ <journalname=filename>
}

# end extends grammar }}}
# journal grammar {{{

token TOP
{
    <journal>
}

token journal
{
    <segment>*
}

proto token segment {*}
token segment:blank { <.blank_line> }
token segment:comment { <.comment_line> }
token segment:entry { <entry> }
token segment:include { <include_line> }
token segment:extends { <extends_line> }

token blank_line
{
    ^^ \h* $$ \n
}

token comment_line
{
    ^^ \h* <.comment> $$ \n
}

regex entry
{
    <header>
    <.gap>*
    <postings>
}

# end journal grammar }}}

# vim: ft=perl6 fdm=marker fdl=0
