use v6;
use lib 'lib';
use Test;
use Config::TOML::Parser::Grammar;

plan 9;

# empty array grammar tests {{{

subtest
{
    my Str $empty_array = '[]';
    my Str $empty_array_space = '[ ]';
    my Str $empty_array_spaces = '[   ]';
    my Str $empty_array_tab = '[	]';
    my Str $empty_array_tabs = '[			]';
    my Str $empty_array_newline = Q:to/EOF/;
    [
    ]
    EOF
    $empty_array_newline .= trim;
    my Str $empty_array_newlines = Q:to/EOF/;
    [


    ]
    EOF
    $empty_array_newlines .= trim;
    my Str $empty_array_newlines_tabbed = Q:to/EOF/;
    [


		]
    EOF
    $empty_array_newlines_tabbed .= trim;

    my $match_empty_array = Config::TOML::Parser::Grammar.parse(
        $empty_array,
        :rule<array>
    );
    my $match_empty_array_space = Config::TOML::Parser::Grammar.parse(
        $empty_array_space,
        :rule<array>
    );
    my $match_empty_array_spaces = Config::TOML::Parser::Grammar.parse(
        $empty_array_spaces,
        :rule<array>
    );
    my $match_empty_array_tab = Config::TOML::Parser::Grammar.parse(
        $empty_array_tab,
        :rule<array>
    );
    my $match_empty_array_tabs = Config::TOML::Parser::Grammar.parse(
        $empty_array_tabs,
        :rule<array>
    );
    my $match_empty_array_newline = Config::TOML::Parser::Grammar.parse(
        $empty_array_newline,
        :rule<array>
    );
    my $match_empty_array_newlines = Config::TOML::Parser::Grammar.parse(
        $empty_array_newlines,
        :rule<array>
    );
    my $match_empty_array_newlines_tabbed = Config::TOML::Parser::Grammar.parse(
        $empty_array_newlines_tabbed,
        :rule<array>
    );

    is(
        $match_empty_array.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($empty_array, :rule<array>)] - 1 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal empty array successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match_empty_array_space.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($empty_array_space, :rule<array>)] - 2 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal empty array (with
        ┃   Success   ┃    single space) successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match_empty_array_spaces.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($empty_array_spaces, :rule<array>)] - 3 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal empty array (with
        ┃   Success   ┃    spaces) successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match_empty_array_tab.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($empty_array_tab, :rule<array>)] - 4 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal empty array (with
        ┃   Success   ┃    single tab) successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match_empty_array_tabs.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($empty_array_tabs, :rule<array>)] - 5 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal empty array (with
        ┃   Success   ┃    tabs) successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match_empty_array_newline.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($empty_array_newline, :rule<array>)] - 6 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal empty array (with
        ┃   Success   ┃    single newline) successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match_empty_array_newlines.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($empty_array_newlines, :rule<array>)] - 7 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal empty array (with
        ┃   Success   ┃    newlines) successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match_empty_array_newlines_tabbed.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($empty_array_newlines_tabbed, :rule<array>)] - 8 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal empty array (with
        ┃   Success   ┃    newlines and tab) successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

# end empty array grammar tests }}}
# array of strings grammar tests {{{

subtest
{
    my Str $array_of_basic_strings = Q:to/EOF/;
    ["red", "maroon", "crimson"]
    EOF
    $array_of_basic_strings .= trim;

    my Str $array_of_basic_strings_newlines = Q:to/EOF/;
    [
        "red",
        "maroon",
        "crimson",
    ]
    EOF
    $array_of_basic_strings_newlines .= trim;

    my Str $array_of_basic_empty_strings = Q:to/EOF/;
    ["", " ", "		"]
    EOF
    $array_of_basic_empty_strings .= trim;

    my Str $array_of_basic_multiline_string = Q:to/EOF/;
    ["""red""",]
    EOF
    $array_of_basic_multiline_string .= trim;

    my Str $array_of_basic_multiline_strings = Q:to/EOF/;
    ["""red""", """maroon""", """crimson"""]
    EOF
    $array_of_basic_multiline_strings .= trim;

    my Str $array_of_basic_multiline_strings_newlines = Q:to/EOF/;
    [
        """
        red \
        maroon \n\
        crimson
        """,
        """
        blue
        aqua
        turquoise
        """, """ brown tan\n auburn""", ]
    EOF
    $array_of_basic_multiline_strings_newlines .= trim;

    my Str $array_of_literal_strings = Q:to/EOF/;
    ['red', 'maroon', 'crimson']
    EOF
    $array_of_literal_strings .= trim;

    my Str $array_of_literal_strings_newlines = Q:to/EOF/;
    [
        'red',
        'maroon',
        'crimson',
    ]
    EOF
    $array_of_literal_strings_newlines .= trim;

    my Str $array_of_literal_empty_strings = Q:to/EOF/;
    ['', ' ', '		']
    EOF
    $array_of_literal_empty_strings .= trim;

    my Str $array_of_literal_multiline_string = Q:to/EOF/;
    ['''red''',]
    EOF
    $array_of_literal_multiline_string .= trim;

    my Str $array_of_literal_multiline_strings = Q:to/EOF/;
    ['''red''', '''maroon''', '''crimson''']
    EOF
    $array_of_literal_multiline_strings .= trim;

    my Str $array_of_literal_multiline_strings_newlines = Q:to/EOF/;
    [
        '''
        red \
        maroon \
        crimson
        ''',
        '''
        blue
        aqua
        turquoise
        ''', ''' brown tan auburn''', ]
    EOF
    $array_of_literal_multiline_strings_newlines .= trim;

    my Str $array_of_mixed_strings = Q:to/EOF/;
    [ "first", 'second', """third""", '''fourth''', "", '', ]
    EOF
    $array_of_mixed_strings .= trim;

    my Str $array_of_difficult_strings = q:to/EOF/;
    [ "] ", " # ", '\ ', '\', '''\ ''', '''\''']
    EOF
    $array_of_difficult_strings .= trim;

    my Str $array_of_difficult_strings_leading_commas = q:to/EOF/;
    [
        "] "
        , " # "
        , '\ '
        , '\'
        , '''\ '''
        , '''\'''
    ]
    EOF
    $array_of_difficult_strings_leading_commas .= trim;




    my $match_array_of_basic_strings = Config::TOML::Parser::Grammar.parse(
        $array_of_basic_strings,
        :rule<array>
    );
    my $match_array_of_basic_strings_newlines = Config::TOML::Parser::Grammar.parse(
        $array_of_basic_strings_newlines,
        :rule<array>
    );
    my $match_array_of_basic_empty_strings = Config::TOML::Parser::Grammar.parse(
        $array_of_basic_empty_strings,
        :rule<array>
    );
    my $match_array_of_basic_multiline_string = Config::TOML::Parser::Grammar.parse(
        $array_of_basic_multiline_string,
        :rule<array>
    );
    my $match_array_of_basic_multiline_strings = Config::TOML::Parser::Grammar.parse(
        $array_of_basic_multiline_strings,
        :rule<array>
    );
    my $match_array_of_basic_multiline_strings_newlines = Config::TOML::Parser::Grammar.parse(
        $array_of_basic_multiline_strings_newlines,
        :rule<array>
    );
    my $match_array_of_literal_strings = Config::TOML::Parser::Grammar.parse(
        $array_of_literal_strings,
        :rule<array>
    );
    my $match_array_of_literal_strings_newlines = Config::TOML::Parser::Grammar.parse(
        $array_of_literal_strings_newlines,
        :rule<array>
    );
    my $match_array_of_literal_empty_strings = Config::TOML::Parser::Grammar.parse(
        $array_of_literal_empty_strings,
        :rule<array>
    );
    my $match_array_of_literal_multiline_string = Config::TOML::Parser::Grammar.parse(
        $array_of_literal_multiline_string,
        :rule<array>
    );
    my $match_array_of_literal_multiline_strings = Config::TOML::Parser::Grammar.parse(
        $array_of_literal_multiline_strings,
        :rule<array>
    );
    my $match_array_of_literal_multiline_strings_newlines = Config::TOML::Parser::Grammar.parse(
        $array_of_literal_multiline_strings_newlines,
        :rule<array>
    );
    my $match_array_of_mixed_strings = Config::TOML::Parser::Grammar.parse(
        $array_of_mixed_strings,
        :rule<array>
    );
    my $match_array_of_difficult_strings = Config::TOML::Parser::Grammar.parse(
        $array_of_difficult_strings,
        :rule<array>
    );
    my $match_array_of_difficult_strings_leading_commas = Config::TOML::Parser::Grammar.parse(
        $array_of_difficult_strings_leading_commas,
        :rule<array>
    );




    is(
        $match_array_of_basic_strings.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($array_of_basic_strings, :rule<array>)] - 9 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of basic strings
        ┃   Success   ┃    successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match_array_of_basic_strings_newlines.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse(
              $array_of_basic_strings_newlines,
              :rule<array>
           )] - 10 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of basic strings
        ┃   Success   ┃    (with newlines) successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match_array_of_basic_empty_strings.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse(
              $array_of_basic_empty_strings,
              :rule<array>
           )] - 11 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of empty basic
        ┃   Success   ┃    strings successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match_array_of_basic_multiline_string.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse(
              $array_of_basic_multiline_string,
              :rule<array>
           )] - 12 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of single basic
        ┃   Success   ┃    multiline string successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match_array_of_basic_multiline_strings.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse(
              $array_of_basic_multiline_strings,
              :rule<array>
           )] - 13 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of basic multiline
        ┃   Success   ┃    strings successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match_array_of_basic_multiline_strings_newlines.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse(
              $array_of_basic_multiline_strings_newlines,
              :rule<array>
           )] - 14 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of basic multiline
        ┃   Success   ┃    strings (with newlines) successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match_array_of_literal_strings.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($array_of_literal_strings, :rule<array>)] - 15 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of literal strings
        ┃   Success   ┃    successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match_array_of_literal_strings_newlines.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse(
              $array_of_literal_strings_newlines,
              :rule<array>
           )] - 16 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of literal strings
        ┃   Success   ┃    (with newlines) successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match_array_of_literal_empty_strings.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse(
              $array_of_literal_empty_strings,
              :rule<array>
           )] - 17 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of empty literal
        ┃   Success   ┃    strings successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match_array_of_literal_multiline_string.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse(
              $array_of_literal_multiline_string,
              :rule<array>
           )] - 18 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of single literal
        ┃   Success   ┃    multiline string successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match_array_of_literal_multiline_strings.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse(
              $array_of_literal_multiline_strings,
              :rule<array>
           )] - 19 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of literal
        ┃   Success   ┃    multiline strings successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match_array_of_literal_multiline_strings_newlines.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse(
              $array_of_literal_multiline_strings_newlines,
              :rule<array>
           )] - 20 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of literal
        ┃   Success   ┃    multiline strings (with newlines) successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match_array_of_mixed_strings.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($array_of_mixed_strings, :rule<array>)] - 21 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of mixed strings
        ┃   Success   ┃    successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match_array_of_difficult_strings.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($array_of_difficult_strings, :rule<array>)] - 22 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of difficult
        ┃   Success   ┃    strings successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match_array_of_difficult_strings_leading_commas.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse(
              $array_of_difficult_strings_leading_commas,
              :rule<array>
           )] - 23 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of difficult
        ┃   Success   ┃    strings (with leading commas) successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

# end array of strings grammar tests }}}
# array of integers grammar tests {{{

subtest
{
    my Str $array_of_integers = '[ 8001, 8001, 8002 ]';
    my Str $array_of_integers_newlines = Q:to/EOF/;
    [
        +99,
        42,
        0,
        -17,
        1_000,
        5_349_221,
        1_2_3_4_5
    ]
    EOF
    $array_of_integers_newlines .= trim;

    my $match_array_of_integers = Config::TOML::Parser::Grammar.parse(
        $array_of_integers,
        :rule<array>
    );
    my $match_array_of_integers_newlines = Config::TOML::Parser::Grammar.parse(
        $array_of_integers_newlines,
        :rule<array>
    );

    is(
        $match_array_of_integers.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($array_of_integers, :rule<array>)] - 24 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of integers
        ┃   Success   ┃    successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match_array_of_integers_newlines.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($array_of_integers_newlines, :rule<array>)] - 25 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of integers
        ┃   Success   ┃    (with newlines) successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

# end array of integers grammar tests }}}
# array of floats grammar tests {{{

subtest
{
    my Str $array_of_floats = '[ 0.0, -1.1, +2.2, -3.3, +4.4, -5.5 ]';
    my Str $array_of_floats_newlines = Q:to/EOF/;
    [
        +1.0,
        3.1415,
        -0.01,
        5_000e+22,
        -1e6,
        -2E-2,
        6.626e-34,
        9_224_617.445_991_228_313,
        1e1_000
    ]
    EOF
    $array_of_floats_newlines .= trim;

    my $match_array_of_floats = Config::TOML::Parser::Grammar.parse(
        $array_of_floats,
        :rule<array>
    );
    my $match_array_of_floats_newlines = Config::TOML::Parser::Grammar.parse(
        $array_of_floats_newlines,
        :rule<array>
    );

    is(
        $match_array_of_floats.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($array_of_floats, :rule<array>)] - 26 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of floats
        ┃   Success   ┃    successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match_array_of_floats_newlines.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($array_of_floats_newlines, :rule<array>)] - 27 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of floats
        ┃   Success   ┃    (with newlines) successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

# end array of floats grammar tests }}}
# array of booleans grammar tests {{{

subtest
{
    my Str $array_of_booleans = '[true,false]';
    my Str $array_of_booleans_newlines = Q:to/EOF/;
    [
        true
        , false
    ]
    EOF
    $array_of_booleans_newlines .= trim;

    my $match_array_of_booleans = Config::TOML::Parser::Grammar.parse(
        $array_of_booleans,
        :rule<array>
    );
    my $match_array_of_booleans_newlines = Config::TOML::Parser::Grammar.parse(
        $array_of_booleans_newlines,
        :rule<array>
    );

    is(
        $match_array_of_booleans.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($array_of_booleans, :rule<array>)] - 28 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of booleans successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match_array_of_booleans_newlines.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($array_of_booleans_newlines, :rule<array>)] - 29 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of booleans
        ┃   Success   ┃    (with newlines) successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

# end array of booleans grammar tests }}}
# array of datetimes grammar tests {{{

subtest
{
    my Str $array_of_date_times = '[1979-05-27T07:32:00Z,]';
    my Str $array_of_date_times_newlines = Q:to/EOF/;
    [
        1979-05-27T07:32:00Z,
        1979-05-27T00:32:00-07:00,
        1979-05-27T00:32:00.999999-07:00
    ]
    EOF
    $array_of_date_times_newlines .= trim;

    my $match_array_of_date_times = Config::TOML::Parser::Grammar.parse(
        $array_of_date_times,
        :rule<array>
    );
    my $match_array_of_date_times_newlines = Config::TOML::Parser::Grammar.parse(
        $array_of_date_times_newlines,
        :rule<array>
    );

    is(
        $match_array_of_date_times.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($array_of_date_times, :rule<array>)] - 30 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of datetimes
        ┃   Success   ┃    successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match_array_of_date_times_newlines.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse(
              $array_of_date_times_newlines,
              :rule<array>
           )] - 31 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of datetimes
        ┃   Success   ┃    (with newlines) successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

# end array of datetimes grammar tests }}}
# array of arrays grammar tests {{{

subtest
{
    my Str $array_of_arrays = '[ [ 1, 2 ], [-3e1_000, +4.56, 5.0] ]';
    my Str $array_of_arrays_newlines = Q:to/EOF/;
    [
        [ [ 1, 2 ], [3, 4, 5] ],
        [
            [ 1, 2 ],
            ["a", "b", "c"]
        ],
        [
            [
                [
                    '''
                    line one
                    line two
                    line three
                    ''',
                    """
                    line four
                    line five
                    line six
                    """
                ],
                [
                    '''
                    line seven
                    line eight
                    line nine
                    ''',
                    """
                    line ten
                    line eleven
                    line twelve
                    """
                ],
            ],
            [
                3,
                6,
                9
            ]
        ]
    ]
    EOF
    $array_of_arrays_newlines .= trim;
    my Str $array_of_empty_arrays = Q:to/EOF/;
    [[[[[]]]]]
    EOF
    $array_of_empty_arrays .= trim;

    my $match_array_of_arrays = Config::TOML::Parser::Grammar.parse(
        $array_of_arrays,
        :rule<array>
    );
    my $match_array_of_arrays_newlines = Config::TOML::Parser::Grammar.parse(
        $array_of_arrays_newlines,
        :rule<array>
    );
    my $match_array_of_empty_arrays = Config::TOML::Parser::Grammar.parse(
        $array_of_empty_arrays,
        :rule<array>
    );

    is(
        $match_array_of_arrays.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($array_of_arrays, :rule<array>)] - 32 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of arrays
        ┃   Success   ┃    successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match_array_of_arrays_newlines.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse(
              $array_of_arrays_newlines,
              :rule<array>
           )] - 33 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of arrays
        ┃   Success   ┃    (with newlines) successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match_array_of_empty_arrays.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse(
              $array_of_empty_arrays,
              :rule<array>
           )] - 34 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of arrays
        ┃   Success   ┃    (with newlines) successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

# end array of arrays grammar tests }}}
# array of inline tables grammar tests {{{

subtest
{
    my Str $array_of_inline_tables = Q:to/EOF/;
    [ { x = 1, y = 2, z = 3 },
      { x = 7, y = 8, z = 9 },
      { x = 2, y = 4, z = 8 } ]
    EOF
    $array_of_inline_tables .= trim;

    my $match_array_of_inline_tables = Config::TOML::Parser::Grammar.parse(
        $array_of_inline_tables,
        :rule<array>
    );

    is(
        $match_array_of_inline_tables.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($array_of_inline_tables, :rule<array>)] - 35 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of inline tables
        ┃   Success   ┃    successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

# end array of inline tables grammar tests }}}
# commented array grammar tests {{{

subtest
{
    my Str $commented_array_of_mixed_strings = Q:to/EOF/;
    [# this is ok
        # this is ok
        'a', # this is ok
        "b",# this is ok
        '''c'''# this is ok
        , """d"""# this is ok
        # this is ok
        # this is ok
        # this is ok
    ]
    EOF
    $commented_array_of_mixed_strings .= trim;
    my Str $commented_array_of_integers = Q:to/EOF/;
    [# this is ok
        # this is ok
        1, # this is ok
        2,# this is ok
        3# this is ok
        # this is ok
        # this is ok
        # this is ok
    ]
    EOF
    $commented_array_of_integers .= trim;
    my Str $commented_array_of_floats = Q:to/EOF/;
    [# this is ok
        # this is ok
        +1.1, # this is ok
        -2e1_000,# this is ok
        0.0000001# this is ok
        # this is ok
        # this is ok
        # this is ok
    ]
    EOF
    $commented_array_of_floats .= trim;
    my Str $commented_array_of_booleans = Q:to/EOF/;
    [# this is ok
        # this is ok
        true, # this is ok
        false,# this is ok
        true# this is ok
        # this is ok
        # this is ok
        # this is ok
    ]
    EOF
    $commented_array_of_booleans .= trim;
    my Str $commented_array_of_date_times = Q:to/EOF/;
    [# this is ok
        # this is ok
        1979-05-27T07:32:00Z, # this is ok
        1979-05-27T00:32:00-07:00,# this is ok
        1979-05-27T00:32:00.999999-07:00,# this is ok
        1979-05-27T07:32:00,# this is ok
        1979-05-27T00:32:00.999999,# this is ok
        1979-05-27# this is ok
        # this is ok
        # this is ok
        # this is ok
    ]
    EOF
    $commented_array_of_date_times .= trim;
    my Str $commented_array_of_arrays = Q:to/EOF/;
    [# this is ok
        # this is ok
        [ [ 1, 2 ], [3, 4, 5] ], # this is ok
        [ [ 1, 2 ], ["a", "b", "c"] ],# this is ok
        [# this is ok
            # this is ok
            [ # this is ok
                # this is ok
                [#this is ok
                    # this is ok
                    # this is ok
                    '''#this is not a comment
                    line one # this is not a comment
                    line two # this is not a comment
                    line three # this is not a comment
                    ''',# this is ok
                    # this is ok
                    # this is ok
                    """
                    line four
                    line five
                    line six
                    """ # this is ok
                    # this is ok
                    # this is ok
                ], # this is ok
                [# this is ok
                    # this is ok
                    # this is ok
                    '''
                    line seven
                    line eight
                    line nine
                    ''', # this is ok
                    # this is ok
                    """
                    line ten
                    line eleven
                    line twelve
                    """#this is ok
                    # this is ok
                    # this is ok
                    # this is ok
                ],# this is ok
            # this is ok
            # this is ok
            # this is ok
            ], # this is ok
            # this is ok
            # this is ok
            [# this is ok
                3,# this is ok
                6,# this is ok
                9# this is ok
            ]# this is ok
        ]# this is ok
        # this is ok
        # this is ok
        # this is ok
    ]
    EOF
    $commented_array_of_arrays .= trim;

    my $match_commented_array_of_mixed_strings = Config::TOML::Parser::Grammar.parse(
        $commented_array_of_mixed_strings,
        :rule<array>
    );
    my $match_commented_array_of_integers = Config::TOML::Parser::Grammar.parse(
        $commented_array_of_integers,
        :rule<array>
    );
    my $match_commented_array_of_floats = Config::TOML::Parser::Grammar.parse(
        $commented_array_of_floats,
        :rule<array>
    );
    my $match_commented_array_of_booleans = Config::TOML::Parser::Grammar.parse(
        $commented_array_of_booleans,
        :rule<array>
    );
    my $match_commented_array_of_date_times = Config::TOML::Parser::Grammar.parse(
        $commented_array_of_date_times,
        :rule<array>
    );
    my $match_commented_array_of_arrays = Config::TOML::Parser::Grammar.parse(
        $commented_array_of_arrays,
        :rule<array>
    );

    is(
        $match_commented_array_of_mixed_strings.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse(
              $commented_array_of_mixed_strings,
              :rule<array>
           )] - 36 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal commented array
        ┃   Success   ┃    of mixed_strings successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_commented_array_of_integers.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($commented_array_of_integers, :rule<array>)] - 37 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal commented array
        ┃   Success   ┃    of integers successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_commented_array_of_floats.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($commented_array_of_floats, :rule<array>)] - 38 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal commented array
        ┃   Success   ┃    of floats successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_commented_array_of_booleans.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($commented_array_of_booleans, :rule<array>)] - 39 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal commented array
        ┃   Success   ┃    of booleans successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_commented_array_of_date_times.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse(
              $commented_array_of_date_times,
              :rule<array>
           )] - 40 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal commented array
        ┃   Success   ┃    of datetimes successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_commented_array_of_arrays.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($commented_array_of_arrays, :rule<array>)] - 41 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal commented array
        ┃   Success   ┃    of arrays successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

# end commented array grammar tests }}}

# vim: ft=perl6 fdm=marker fdl=0
