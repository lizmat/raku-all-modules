use v6;
use lib 'lib';
use Test;
use Config::TOML::Parser::Actions;
use Config::TOML::Parser::Grammar;

plan 9;

# empty array grammar-actions tests {{{

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

    my Config::TOML::Parser::Actions $actions .= new;
    my $match_empty_array = Config::TOML::Parser::Grammar.parse(
        $empty_array,
        :$actions,
        :rule<array>
    );
    my $match_empty_array_space = Config::TOML::Parser::Grammar.parse(
        $empty_array_space,
        :$actions,
        :rule<array>
    );
    my $match_empty_array_spaces = Config::TOML::Parser::Grammar.parse(
        $empty_array_spaces,
        :$actions,
        :rule<array>
    );
    my $match_empty_array_tab = Config::TOML::Parser::Grammar.parse(
        $empty_array_tab,
        :$actions,
        :rule<array>
    );
    my $match_empty_array_tabs = Config::TOML::Parser::Grammar.parse(
        $empty_array_tabs,
        :$actions,
        :rule<array>
    );
    my $match_empty_array_newline = Config::TOML::Parser::Grammar.parse(
        $empty_array_newline,
        :$actions,
        :rule<array>
    );
    my $match_empty_array_newlines = Config::TOML::Parser::Grammar.parse(
        $empty_array_newlines,
        :$actions,
        :rule<array>
    );
    my $match_empty_array_newlines_tabbed = Config::TOML::Parser::Grammar.parse(
        $empty_array_newlines_tabbed,
        :$actions,
        :rule<array>
    );

    is(
        $match_empty_array.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($empty_array, :rule<array>)] - 1 of 123
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
        ♪ [Grammar.parse($empty_array_space, :rule<array>)] - 2 of 123
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
        ♪ [Grammar.parse($empty_array_spaces, :rule<array>)] - 3 of 123
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
        ♪ [Grammar.parse($empty_array_tab, :rule<array>)] - 4 of 123
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
        ♪ [Grammar.parse($empty_array_tabs, :rule<array>)] - 5 of 123
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
        ♪ [Grammar.parse($empty_array_newline, :rule<array>)] - 6 of 123
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
        ♪ [Grammar.parse($empty_array_newlines, :rule<array>)] - 7 of 123
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
        ♪ [Grammar.parse($empty_array_newlines_tabbed, :rule<array>)] - 8 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal empty array (with
        ┃   Success   ┃    newlines and tab) successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match_empty_array.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 9 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_empty_array.made.WHAT ~~ Array
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_empty_array_space.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 10 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_empty_array_space.made.WHAT ~~ Array
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_empty_array_spaces.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 11 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_empty_array_spaces.made.WHAT ~~ Array
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_empty_array_tab.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 12 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_empty_array_tab.made.WHAT ~~ Array
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_empty_array_tabs.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 13 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_empty_array_tabs.made.WHAT ~~ Array
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_empty_array_newline.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 14 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_empty_array_newline.made.WHAT ~~ Array
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_empty_array_newlines.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 15 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_empty_array_newlines.made.WHAT ~~ Array
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_empty_array_newlines_tabbed.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 16 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_empty_array_newlines_tabbed.made.WHAT
        ┃   Success   ┃        ~~ Array
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match_empty_array.made,
        [],
        q:to/EOF/
        ♪ [Is expected array value?] - 17 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_empty_array.made ~~ []
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_empty_array_space.made,
        [],
        q:to/EOF/
        ♪ [Is expected array value?] - 18 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_empty_array_space.made ~~ []
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_empty_array_spaces.made,
        [],
        q:to/EOF/
        ♪ [Is expected array value?] - 19 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_empty_array_spaces.made ~~ []
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_empty_array_tab.made,
        [],
        q:to/EOF/
        ♪ [Is expected array value?] - 20 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_empty_array_tab.made ~~ []
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_empty_array_tabs.made,
        [],
        q:to/EOF/
        ♪ [Is expected array value?] - 21 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_empty_array_tabs.made ~~ []
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_empty_array_newline.made,
        [],
        q:to/EOF/
        ♪ [Is expected array value?] - 22 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_empty_array_newline.made ~~ []
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_empty_array_newlines.made,
        [],
        q:to/EOF/
        ♪ [Is expected array value?] - 23 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_empty_array_newlines.made ~~ []
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_empty_array_newlines_tabbed.made,
        [],
        q:to/EOF/
        ♪ [Is expected array value?] - 24 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_empty_array_newlines_tabbed.made
        ┃   Success   ┃        ~~ []
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

# end empty array grammar-actions tests }}}
# array of strings grammar-actions tests {{{

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

    my Config::TOML::Parser::Actions $actions .= new;
    my $match_array_of_basic_strings = Config::TOML::Parser::Grammar.parse(
        $array_of_basic_strings,
        :$actions,
        :rule<array>
    );
    my $match_array_of_basic_strings_newlines = Config::TOML::Parser::Grammar.parse(
        $array_of_basic_strings_newlines,
        :$actions,
        :rule<array>
    );
    my $match_array_of_basic_empty_strings = Config::TOML::Parser::Grammar.parse(
        $array_of_basic_empty_strings,
        :$actions,
        :rule<array>
    );
    my $match_array_of_basic_multiline_string = Config::TOML::Parser::Grammar.parse(
        $array_of_basic_multiline_string,
        :$actions,
        :rule<array>
    );
    my $match_array_of_basic_multiline_strings = Config::TOML::Parser::Grammar.parse(
        $array_of_basic_multiline_strings,
        :$actions,
        :rule<array>
    );
    my $match_array_of_basic_multiline_strings_newlines = Config::TOML::Parser::Grammar.parse(
        $array_of_basic_multiline_strings_newlines,
        :$actions,
        :rule<array>
    );
    my $match_array_of_literal_strings = Config::TOML::Parser::Grammar.parse(
        $array_of_literal_strings,
        :$actions,
        :rule<array>
    );
    my $match_array_of_literal_strings_newlines = Config::TOML::Parser::Grammar.parse(
        $array_of_literal_strings_newlines,
        :$actions,
        :rule<array>
    );
    my $match_array_of_literal_empty_strings = Config::TOML::Parser::Grammar.parse(
        $array_of_literal_empty_strings,
        :$actions,
        :rule<array>
    );
    my $match_array_of_literal_multiline_string = Config::TOML::Parser::Grammar.parse(
        $array_of_literal_multiline_string,
        :$actions,
        :rule<array>
    );
    my $match_array_of_literal_multiline_strings = Config::TOML::Parser::Grammar.parse(
        $array_of_literal_multiline_strings,
        :$actions,
        :rule<array>
    );
    my $match_array_of_literal_multiline_strings_newlines = Config::TOML::Parser::Grammar.parse(
        $array_of_literal_multiline_strings_newlines,
        :$actions,
        :rule<array>
    );
    my $match_array_of_mixed_strings = Config::TOML::Parser::Grammar.parse(
        $array_of_mixed_strings,
        :$actions,
        :rule<array>
    );
    my $match_array_of_difficult_strings = Config::TOML::Parser::Grammar.parse(
        $array_of_difficult_strings,
        :$actions,
        :rule<array>
    );
    my $match_array_of_difficult_strings_leading_commas = Config::TOML::Parser::Grammar.parse(
        $array_of_difficult_strings_leading_commas,
        :$actions,
        :rule<array>
    );

    is(
        $match_array_of_basic_strings.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($array_of_basic_strings, :rule<array>)] - 25 of 123
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
           )] - 26 of 123
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
           )] - 27 of 123
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
           )] - 28 of 123
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
           )] - 29 of 123
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
           )] - 30 of 123
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
        ♪ [Grammar.parse($array_of_literal_strings, :rule<array>)] - 31 of 123
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
           )] - 32 of 123
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
           )] - 33 of 123
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
           )] - 34 of 123
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
           )] - 35 of 123
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
           )] - 36 of 123
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
        ♪ [Grammar.parse($array_of_mixed_strings, :rule<array>)] - 37 of 123
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
        ♪ [Grammar.parse($array_of_difficult_strings, :rule<array>)] - 38 of 123
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
           )] - 39 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of difficult
        ┃   Success   ┃    strings (with leading commas) successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match_array_of_basic_strings.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 40 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_array_of_basic_strings.made.WHAT
        ┃   Success   ┃        ~~ Array
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_array_of_basic_strings_newlines.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 41 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_array_of_basic_strings_newlines.made.WHAT
        ┃   Success   ┃        ~~ Array
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_array_of_basic_empty_strings.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 42 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_array_of_basic_empty_strings.made.WHAT
        ┃   Success   ┃        ~~ Array
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_array_of_basic_multiline_string.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 43 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_array_of_basic_multiline_string.made.WHAT
        ┃   Success   ┃        ~~ Array
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_array_of_basic_multiline_strings.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 44 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_array_of_basic_multiline_strings.made.WHAT
        ┃   Success   ┃        ~~ Array
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_array_of_basic_multiline_strings_newlines.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 45 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_array_of_basic_multiline_strings_newlines
        ┃   Success   ┃        .made
        ┃             ┃        .WHAT ~~ Array
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_array_of_literal_strings.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 46 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_array_of_literal_strings.made.WHAT
        ┃   Success   ┃        ~~ Array
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_array_of_literal_strings_newlines.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 47 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_array_of_literal_strings_newlines
        ┃   Success   ┃        .made
        ┃             ┃        .WHAT ~~ Array
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_array_of_literal_empty_strings.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 48 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_array_of_literal_empty_strings.made.WHAT
        ┃   Success   ┃        ~~ Array
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_array_of_literal_multiline_string.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 49 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_array_of_literal_multiline_string
        ┃   Success   ┃        .made
        ┃             ┃        .WHAT ~~ Array
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_array_of_literal_multiline_strings.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 50 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_array_of_literal_multiline_strings
        ┃   Success   ┃        .made
        ┃             ┃        .WHAT ~~ Array
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_array_of_literal_multiline_strings_newlines.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 51 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_array_of_literal_multiline_strings_newlines
        ┃   Success   ┃        .made
        ┃             ┃        .WHAT ~~ Array
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_array_of_mixed_strings.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 52 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_array_of_mixed_strings.made.WHAT
        ┃   Success   ┃        ~~ Array
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_array_of_difficult_strings.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 53 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_array_of_difficult_strings.made.WHAT
        ┃   Success   ┃        ~~ Array
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_array_of_difficult_strings_leading_commas.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 54 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_array_of_difficult_strings_leading_commas
        ┃   Success   ┃        .made
        ┃             ┃        .WHAT ~~ Array
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match_array_of_basic_strings.made,
        ["red", "maroon", "crimson"],
        q:to/EOF/
        ♪ [Is expected array value?] - 55 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_array_of_basic_strings.made
        ┃   Success   ┃        ~~ ["red", "maroon", "crimson"]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_array_of_basic_strings_newlines.made,
        ["red", "maroon", "crimson"],
        q:to/EOF/
        ♪ [Is expected array value?] - 56 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_array_of_basic_strings_newlines.made
        ┃   Success   ┃        ~~ ["red", "maroon", "crimson"]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_array_of_basic_empty_strings.made,
        ["", " ", "\t\t"],
        q:to/EOF/
        ♪ [Is expected array value?] - 57 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_array_of_basic_empty_strings.made
        ┃   Success   ┃        ~~ ["", " ", "\t\t"]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_array_of_basic_multiline_string.made,
        ["red"],
        q:to/EOF/
        ♪ [Is expected array value?] - 58 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_array_of_basic_multiline_string.made
        ┃   Success   ┃        ~~ ["red"]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_array_of_basic_multiline_strings.made,
        ["red", "maroon", "crimson"],
        q:to/EOF/
        ♪ [Is expected array value?] - 59 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_array_of_basic_multiline_strings.made
        ┃   Success   ┃        ~~ ["red", "maroon", "crimson"]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    # leading whitespace in this array is because TOML parser does not
    # parse heredocs like Perl 6, leading spaces on the outside edges
    # of multiline string delimiters are preserved
    is(
        $match_array_of_basic_multiline_strings_newlines.made,
        [
            "    red maroon \ncrimson\n    ",
            "    blue\n    aqua\n    turquoise\n    ",
            " brown tan\n auburn"
        ],
        q:to/EOF/
        ♪ [Is expected array value?] - 60 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_array_of_basic_multiline_strings_newlines
        ┃   Success   ┃        .made ~~ [ ... ]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_array_of_literal_strings.made,
        ["red", "maroon", "crimson"],
        q:to/EOF/
        ♪ [Is expected array value?] - 61 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_array_of_literal_strings.made
        ┃   Success   ┃        ~~ ["red", "maroon", "crimson"]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_array_of_literal_strings_newlines.made,
        ["red", "maroon", "crimson"],
        q:to/EOF/
        ♪ [Is expected array value?] - 62 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_array_of_literal_strings_newlines
        ┃   Success   ┃        .made ~~ ["red", "maroon", "crimson"]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_array_of_literal_empty_strings.made,
        ["", " ", "\t\t"],
        q:to/EOF/
        ♪ [Is expected array value?] - 63 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_array_of_literal_empty_strings.made
        ┃   Success   ┃        ~~ ["", " ", "\t\t"]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_array_of_literal_multiline_string.made,
        ["red"],
        q:to/EOF/
        ♪ [Is expected array value?] - 64 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_array_of_literal_multiline_string
        ┃   Success   ┃        .made ~~ ["red"]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_array_of_literal_multiline_strings.made,
        ["red", "maroon", "crimson"],
        q:to/EOF/
        ♪ [Is expected array value?] - 65 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_array_of_literal_multiline_strings
        ┃   Success   ┃        .made ~~ ["red", "maroon", "crimson"]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_array_of_literal_multiline_strings_newlines.made,
        [
            "    red \\\n    maroon \\\n    crimson\n    ",
            "    blue\n    aqua\n    turquoise\n    ",
            " brown tan auburn"
        ],
        q:to/EOF/
        ♪ [Is expected array value?] - 66 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_array_of_literal_multiline_strings_newlines
        ┃   Success   ┃        .made ~~ [ ... ]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_array_of_mixed_strings.made,
        ["first", "second", "third", "fourth", "", ""],
        q:to/EOF/
        ♪ [Is expected array value?] - 67 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_array_of_mixed_strings.made
        ┃   Success   ┃        ~~ ["first", "second", "third", "fourth", "", ""]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_array_of_difficult_strings.made,
        ["] ", " # ", "\\ ", "\\", "\\ ", "\\"],
        q:to/EOF/
        ♪ [Is expected array value?] - 68 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_array_of_difficult_strings.made
        ┃   Success   ┃        ~~ ["] ", " # ", "\\ ", "\\", "\\ ", "\\"]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_array_of_difficult_strings_leading_commas.made,
        ["] ", " # ", "\\ ", "\\", "\\ ", "\\"],
        q:to/EOF/
        ♪ [Is expected array value?] - 69 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_array_of_difficult_strings_leading_commas
        ┃   Success   ┃        .made ~~
        ┃             ┃             ["] ", " # ", "\\ ", "\\", "\\ ", "\\"]
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

# end array of strings grammar-actions tests }}}
# array of integers grammar-actions tests {{{

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

    my Config::TOML::Parser::Actions $actions .= new;
    my $match_array_of_integers = Config::TOML::Parser::Grammar.parse(
        $array_of_integers,
        :$actions,
        :rule<array>
    );
    my $match_array_of_integers_newlines = Config::TOML::Parser::Grammar.parse(
        $array_of_integers_newlines,
        :$actions,
        :rule<array>
    );

    is(
        $match_array_of_integers.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($array_of_integers, :rule<array>)] - 70 of 123
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
        ♪ [Grammar.parse($array_of_integers_newlines, :rule<array>)] - 71 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of integers
        ┃   Success   ┃    (with newlines) successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match_array_of_integers.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 72 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_array_of_integers.made.WHAT
        ┃   Success   ┃        ~~ Array[Int]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_array_of_integers_newlines.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 73 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_array_of_integers_newlines.made.WHAT
        ┃   Success   ┃        ~~ Array
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match_array_of_integers.made,
        [8001, 8001, 8002],
        q:to/EOF/
        ♪ [Is expected array value?] - 74 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_array_of_integers.made
        ┃   Success   ┃        ~~ [8001, 8001, 8002]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_array_of_integers_newlines.made,
        [99, 42, 0, -17, 1000, 5349221, 12345],
        q:to/EOF/
        ♪ [Is expected array value?] - 75 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_array_of_integers_newlines.made
        ┃   Success   ┃        ~~ [99, 42, 0, -17, 1000, 5349221, 12345]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

# end array of integers grammar-actions tests }}}
# array of floats grammar-actions tests {{{

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

    my Config::TOML::Parser::Actions $actions .= new;
    my $match_array_of_floats = Config::TOML::Parser::Grammar.parse(
        $array_of_floats,
        :$actions,
        :rule<array>
    );
    my $match_array_of_floats_newlines = Config::TOML::Parser::Grammar.parse(
        $array_of_floats_newlines,
        :$actions,
        :rule<array>
    );

    is(
        $match_array_of_floats.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($array_of_floats, :rule<array>)] - 76 of 123
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
        ♪ [Grammar.parse($array_of_floats_newlines, :rule<array>)] - 77 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of floats
        ┃   Success   ┃    (with newlines) successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match_array_of_floats.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 78 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_array_of_floats.made.WHAT ~~ Array
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_array_of_floats_newlines.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 79 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_array_of_floats_newlines.made.WHAT
        ┃   Success   ┃        ~~ Array
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match_array_of_floats.made,
        [0.0, -1.1, 2.2, -3.3, 4.4, -5.5],
        q:to/EOF/
        ♪ [Is expected array value?] - 80 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_array_of_floats.made
        ┃   Success   ┃        ~~ [0.0, -1.1, 2.2, -3.3, 4.4, -5.5]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_array_of_floats_newlines.made,
        [
            1.0,
            3.1415,
            -0.01,
            5000e22,
            -1e6,
            -2E-2,
            6.626e-34,
            9224617.445991228313,
            1e1000
        ],
        q:to/EOF/
        ♪ [Is expected array value?] - 81 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_array_of_floats_newlines.made.WHAT
        ┃   Success   ┃        ~~ [ ... ]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

# end array of floats grammar-actions tests }}}
# array of booleans grammar-actions tests {{{

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

    my Config::TOML::Parser::Actions $actions .= new;
    my $match_array_of_booleans = Config::TOML::Parser::Grammar.parse(
        $array_of_booleans,
        :$actions,
        :rule<array>
    );
    my $match_array_of_booleans_newlines = Config::TOML::Parser::Grammar.parse(
        $array_of_booleans_newlines,
        :$actions,
        :rule<array>
    );

    is(
        $match_array_of_booleans.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($array_of_booleans, :rule<array>)] - 82 of 123
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
        ♪ [Grammar.parse($array_of_booleans_newlines, :rule<array>)] - 83 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of booleans
        ┃   Success   ┃    (with newlines) successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match_array_of_booleans.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 84 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_array_of_booleans.made.WHAT ~~ Array
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_array_of_booleans_newlines.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 85 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_array_of_booleans_newlines.made.WHAT ~~ Array
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match_array_of_booleans.made,
        [True, False],
        q:to/EOF/
        ♪ [Is expected array value?] - 86 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_array_of_booleans.made ~~ [True, False]
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_array_of_booleans_newlines.made,
        [True, False],
        q:to/EOF/
        ♪ [Is expected array value?] - 87 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_array_of_booleans_newlines.made
        ┃   Success   ┃        ~~ [True, False]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

# end array of booleans grammar-actions tests }}}
# array of datetimes grammar-actions tests {{{

subtest
{
    my Str $array_of_date_times = '[1979-05-27T07:32:00Z,]';
    my Str $array_of_date_times_newlines = Q:to/EOF/;
    [
        1979-05-27T07:32:00Z,
        1979-05-27T00:32:00-07:00,
        1979-05-27T00:32:00.999999-07:00,
        1979-05-27T07:32:00,
        1979-05-27T00:32:00.999999,
        1979-05-27
    ]
    EOF
    $array_of_date_times_newlines .= trim;

    # assume UTC when local offset unspecified in TOML dates
    my Config::TOML::Parser::Actions $actions .= new(:date_local_offset(0));
    my $match_array_of_date_times = Config::TOML::Parser::Grammar.parse(
        $array_of_date_times,
        :$actions,
        :rule<array>
    );
    my $match_array_of_date_times_newlines = Config::TOML::Parser::Grammar.parse(
        $array_of_date_times_newlines,
        :$actions,
        :rule<array>
    );

    is(
        $match_array_of_date_times.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($array_of_date_times, :rule<array>)] - 88 of 123
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
           )] - 89 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of datetimes
        ┃   Success   ┃    (with newlines) successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match_array_of_date_times.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 90 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_array_of_date_times.made.WHAT ~~ Array
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_array_of_date_times_newlines.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 91 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_array_of_date_times_newlines.made.WHAT
        ┃   Success   ┃        ~~ Array
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match_array_of_date_times.made,
        ['1979-05-27T07:32:00Z'],
        q:to/EOF/
        ♪ [Is expected array value?] - 92 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_array_of_date_times.made ~~ [ ... ]
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_array_of_date_times_newlines.made,
        [
            '1979-05-27T07:32:00Z',
            '1979-05-27T00:32:00-07:00',
            '1979-05-27T00:32:00.999999-07:00',
            '1979-05-27T07:32:00Z',
            '1979-05-27T00:32:00.999999Z',
            '1979-05-27T00:00:00Z'
        ],
        q:to/EOF/
        ♪ [Is expected array value?] - 93 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_array_of_date_times_newlines.made
        ┃   Success   ┃        ~~ [ ... ]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

# end array of datetimes grammar-actions tests }}}
# array of arrays grammar-actions tests {{{

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

    my Config::TOML::Parser::Actions $actions .= new;
    my $match_array_of_arrays = Config::TOML::Parser::Grammar.parse(
        $array_of_arrays,
        :$actions,
        :rule<array>
    );
    my $match_array_of_arrays_newlines = Config::TOML::Parser::Grammar.parse(
        $array_of_arrays_newlines,
        :$actions,
        :rule<array>
    );
    my $match_array_of_empty_arrays = Config::TOML::Parser::Grammar.parse(
        $array_of_empty_arrays,
        :$actions,
        :rule<array>
    );

    is(
        $match_array_of_arrays.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($array_of_arrays, :rule<array>)] - 94 of 123
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
           )] - 95 of 123
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
           )] - 96 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of arrays
        ┃   Success   ┃    (with newlines) successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match_array_of_arrays.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 97 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_array_of_arrays.made.WHAT ~~ Array
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_array_of_arrays_newlines.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 98 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_array_of_arrays_newlines.made.WHAT ~~ Array
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_array_of_empty_arrays.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 99 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_array_of_empty_arrays.made.WHAT ~~ Array
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match_array_of_arrays.made,
        [[1, 2], [-Inf, 4.56, 5.0]],
        q:to/EOF/
        ♪ [Is expected array value?] - 100 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_array_of_arrays.made ~~ [ ... ]
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_array_of_arrays_newlines.made,
        [
            [[1, 2], [3, 4, 5]],
            [[1, 2], ["a", "b", "c"]],
            [
                [
                    ["                line one\n                line two\n                line three\n                ", "                line four\n                line five\n                line six\n                "],
                    ["                line seven\n                line eight\n                line nine\n                ", "                line ten\n                line eleven\n                line twelve\n                "]
                ],
                [3, 6, 9]
            ]
        ],
        q:to/EOF/
        ♪ [Is expected array value?] - 101 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_array_of_arrays_newlines.made ~~ [ ... ]
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_array_of_empty_arrays.made,
        [[[[[]]]]],
        q:to/EOF/
        ♪ [Is expected array value?] - 102 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_array_of_empty_arrays.made ~~ [ ... ]
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

# end array of arrays grammar-actions tests }}}
# array of inline tables grammar-actions tests {{{

subtest
{
    my Str $array_of_inline_tables = Q:to/EOF/;
    [ { x = 1, y = 2, z = 3 },
      { x = 7, y = 8, z = 9 },
      { x = 2, y = 4, z = 8 } ]
    EOF
    $array_of_inline_tables .= trim;

    my Config::TOML::Parser::Actions $actions .= new;
    my $match_array_of_inline_tables = Config::TOML::Parser::Grammar.parse(
        $array_of_inline_tables,
        :$actions,
        :rule<array>
    );

    is(
        $match_array_of_inline_tables.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($array_of_inline_tables, :rule<array>)] - 103 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of inline tables
        ┃   Success   ┃    successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match_array_of_inline_tables.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 104 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_array_of_inline_tables.made.WHAT ~~ Array
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match_array_of_inline_tables.made,
        [
            [ x => 1, y => 2, z => 3 ],
            [ x => 7, y => 8, z => 9 ],
            [ x => 2, y => 4, z => 8 ]
        ],
        q:to/EOF/
        ♪ [Is expected array value?] - 105 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_array_of_inline_tables.made ~~ [ ... ]
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

# end array of inline tables grammar-actions tests }}}
# commented array grammar-actions tests {{{

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

    # assume UTC when local offset unspecified in TOML dates
    my Config::TOML::Parser::Actions $actions .= new(:date_local_offset(0));
    my $match_commented_array_of_mixed_strings = Config::TOML::Parser::Grammar.parse(
        $commented_array_of_mixed_strings,
        :$actions,
        :rule<array>
    );
    my $match_commented_array_of_integers = Config::TOML::Parser::Grammar.parse(
        $commented_array_of_integers,
        :$actions,
        :rule<array>
    );
    my $match_commented_array_of_floats = Config::TOML::Parser::Grammar.parse(
        $commented_array_of_floats,
        :$actions,
        :rule<array>
    );
    my $match_commented_array_of_booleans = Config::TOML::Parser::Grammar.parse(
        $commented_array_of_booleans,
        :$actions,
        :rule<array>
    );
    my $match_commented_array_of_date_times = Config::TOML::Parser::Grammar.parse(
        $commented_array_of_date_times,
        :$actions,
        :rule<array>
    );
    my $match_commented_array_of_arrays = Config::TOML::Parser::Grammar.parse(
        $commented_array_of_arrays,
        :$actions,
        :rule<array>
    );

    is(
        $match_commented_array_of_mixed_strings.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse(
              $commented_array_of_mixed_strings,
              :rule<array>
           )] - 106 of 123
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
        ♪ [Grammar.parse($commented_array_of_integers, :rule<array>)] - 107 of 123
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
        ♪ [Grammar.parse($commented_array_of_floats, :rule<array>)] - 108 of 123
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
        ♪ [Grammar.parse($commented_array_of_booleans, :rule<array>)] - 109 of 123
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
           )] - 110 of 123
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
        ♪ [Grammar.parse($commented_array_of_arrays, :rule<array>)] - 111 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal commented array
        ┃   Success   ┃    of arrays successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match_commented_array_of_mixed_strings.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 112 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_commented_array_of_mixed_strings.made.WHAT
        ┃   Success   ┃        ~~ Array
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_commented_array_of_integers.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 113 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_commented_array_of_integers.made.WHAT
        ┃   Success   ┃        ~~ Array
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_commented_array_of_floats.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 114 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_commented_array_of_floats.made.WHAT
        ┃   Success   ┃        ~~ Array
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_commented_array_of_booleans.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 115 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_commented_array_of_booleans.made.WHAT
        ┃   Success   ┃        ~~ Array
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_commented_array_of_date_times.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 116 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_commented_array_of_date_times.made.WHAT
        ┃   Success   ┃        ~~ Array
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_commented_array_of_arrays.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 117 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_commented_array_of_arrays.made.WHAT
        ┃   Success   ┃        ~~ Array
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match_commented_array_of_mixed_strings.made,
        ["a", "b", "c", "d"],
        q:to/EOF/
        ♪ [Is expected array value?] - 118 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_commented_array_of_mixed_strings.made
        ┃   Success   ┃        ~~ [ ... ]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_commented_array_of_integers.made,
        [1, 2, 3],
        q:to/EOF/
        ♪ [Is expected array value?] - 119 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_commented_array_of_integers.made
        ┃   Success   ┃        ~~ [ ... ]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_commented_array_of_floats.made,
        [1.1, -2e1000, 0.0000001],
        q:to/EOF/
        ♪ [Is expected array value?] - 120 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_commented_array_of_floats.made
        ┃   Success   ┃        ~~ [ ... ]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_commented_array_of_booleans.made,
        [True, False, True],
        q:to/EOF/
        ♪ [Is expected array value?] - 121 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_commented_array_of_booleans.made
        ┃   Success   ┃        ~~ [ ... ]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_commented_array_of_date_times.made,
        [
            '1979-05-27T07:32:00Z',
            '1979-05-27T00:32:00-07:00',
            '1979-05-27T00:32:00.999999-07:00',
            '1979-05-27T07:32:00Z',
            '1979-05-27T00:32:00.999999Z',
            '1979-05-27T00:00:00Z'
        ],
        q:to/EOF/
        ♪ [Is expected array value?] - 122 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_commented_array_of_date_times.made
        ┃   Success   ┃        ~~ [ ... ]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_commented_array_of_arrays.made,
        [
            [
                [1, 2],
                [3, 4, 5]
            ],
            [
                [1, 2],
                ["a", "b", "c"]
            ],
            [
                [
                    ["#this is not a comment\n                line one # this is not a comment\n                line two # this is not a comment\n                line three # this is not a comment\n                ", "                line four\n                line five\n                line six\n                "],
                    ["                line seven\n                line eight\n                line nine\n                ", "                line ten\n                line eleven\n                line twelve\n                "]
                ],
                [3, 6, 9]
            ]
        ],
        q:to/EOF/
        ♪ [Is expected array value?] - 123 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_commented_array_of_arrays.made
        ┃   Success   ┃        ~~ [ ... ]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

# end commented array grammar-actions tests }}}

# vim: ft=perl6 fdm=marker fdl=0
