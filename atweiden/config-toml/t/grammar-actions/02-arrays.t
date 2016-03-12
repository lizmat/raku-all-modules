use v6;
use lib 'lib';
use Test;
use Config::TOML::Parser::Actions;
use Config::TOML::Parser::Grammar;

plan 9;

# empty array grammar-actions tests {{{

subtest
{
    my Str $empty-array = '[]';
    my Str $empty-array-space = '[ ]';
    my Str $empty-array-spaces = '[   ]';
    my Str $empty-array-tab = '[	]';
    my Str $empty-array-tabs = '[			]';
    my Str $empty-array-newline = Q:to/EOF/;
    [
    ]
    EOF
    $empty-array-newline .= trim;
    my Str $empty-array-newlines = Q:to/EOF/;
    [


    ]
    EOF
    $empty-array-newlines .= trim;
    my Str $empty-array-newlines-tabbed = Q:to/EOF/;
    [


		]
    EOF
    $empty-array-newlines-tabbed .= trim;

    my Config::TOML::Parser::Actions $actions .= new;
    my $match-empty-array = Config::TOML::Parser::Grammar.parse(
        $empty-array,
        :$actions,
        :rule<array>
    );
    my $match-empty-array-space = Config::TOML::Parser::Grammar.parse(
        $empty-array-space,
        :$actions,
        :rule<array>
    );
    my $match-empty-array-spaces = Config::TOML::Parser::Grammar.parse(
        $empty-array-spaces,
        :$actions,
        :rule<array>
    );
    my $match-empty-array-tab = Config::TOML::Parser::Grammar.parse(
        $empty-array-tab,
        :$actions,
        :rule<array>
    );
    my $match-empty-array-tabs = Config::TOML::Parser::Grammar.parse(
        $empty-array-tabs,
        :$actions,
        :rule<array>
    );
    my $match-empty-array-newline = Config::TOML::Parser::Grammar.parse(
        $empty-array-newline,
        :$actions,
        :rule<array>
    );
    my $match-empty-array-newlines = Config::TOML::Parser::Grammar.parse(
        $empty-array-newlines,
        :$actions,
        :rule<array>
    );
    my $match-empty-array-newlines-tabbed = Config::TOML::Parser::Grammar.parse(
        $empty-array-newlines-tabbed,
        :$actions,
        :rule<array>
    );

    is(
        $match-empty-array.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($empty-array, :rule<array>)] - 1 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal empty array successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-empty-array-space.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($empty-array-space, :rule<array>)] - 2 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal empty array (with
        ┃   Success   ┃    single space) successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-empty-array-spaces.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($empty-array-spaces, :rule<array>)] - 3 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal empty array (with
        ┃   Success   ┃    spaces) successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-empty-array-tab.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($empty-array-tab, :rule<array>)] - 4 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal empty array (with
        ┃   Success   ┃    single tab) successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-empty-array-tabs.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($empty-array-tabs, :rule<array>)] - 5 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal empty array (with
        ┃   Success   ┃    tabs) successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-empty-array-newline.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($empty-array-newline, :rule<array>)] - 6 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal empty array (with
        ┃   Success   ┃    single newline) successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-empty-array-newlines.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($empty-array-newlines, :rule<array>)] - 7 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal empty array (with
        ┃   Success   ┃    newlines) successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-empty-array-newlines-tabbed.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($empty-array-newlines-tabbed, :rule<array>)] - 8 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal empty array (with
        ┃   Success   ┃    newlines and tab) successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-empty-array.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 9 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-empty-array.made.WHAT ~~ Array
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-empty-array-space.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 10 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-empty-array-space.made.WHAT ~~ Array
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-empty-array-spaces.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 11 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-empty-array-spaces.made.WHAT ~~ Array
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-empty-array-tab.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 12 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-empty-array-tab.made.WHAT ~~ Array
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-empty-array-tabs.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 13 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-empty-array-tabs.made.WHAT ~~ Array
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-empty-array-newline.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 14 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-empty-array-newline.made.WHAT ~~ Array
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-empty-array-newlines.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 15 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-empty-array-newlines.made.WHAT ~~ Array
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-empty-array-newlines-tabbed.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 16 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-empty-array-newlines-tabbed.made.WHAT
        ┃   Success   ┃        ~~ Array
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-empty-array.made,
        [],
        q:to/EOF/
        ♪ [Is expected array value?] - 17 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-empty-array.made ~~ []
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-empty-array-space.made,
        [],
        q:to/EOF/
        ♪ [Is expected array value?] - 18 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-empty-array-space.made ~~ []
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-empty-array-spaces.made,
        [],
        q:to/EOF/
        ♪ [Is expected array value?] - 19 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-empty-array-spaces.made ~~ []
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-empty-array-tab.made,
        [],
        q:to/EOF/
        ♪ [Is expected array value?] - 20 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-empty-array-tab.made ~~ []
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-empty-array-tabs.made,
        [],
        q:to/EOF/
        ♪ [Is expected array value?] - 21 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-empty-array-tabs.made ~~ []
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-empty-array-newline.made,
        [],
        q:to/EOF/
        ♪ [Is expected array value?] - 22 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-empty-array-newline.made ~~ []
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-empty-array-newlines.made,
        [],
        q:to/EOF/
        ♪ [Is expected array value?] - 23 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-empty-array-newlines.made ~~ []
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-empty-array-newlines-tabbed.made,
        [],
        q:to/EOF/
        ♪ [Is expected array value?] - 24 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-empty-array-newlines-tabbed.made
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
    my Str $array-of-basic-strings = Q:to/EOF/;
    ["red", "maroon", "crimson"]
    EOF
    $array-of-basic-strings .= trim;

    my Str $array-of-basic-strings-newlines = Q:to/EOF/;
    [
        "red",
        "maroon",
        "crimson",
    ]
    EOF
    $array-of-basic-strings-newlines .= trim;

    my Str $array-of-basic-empty-strings = Q:to/EOF/;
    ["", " ", "		"]
    EOF
    $array-of-basic-empty-strings .= trim;

    my Str $array-of-basic-multiline-string = Q:to/EOF/;
    ["""red""",]
    EOF
    $array-of-basic-multiline-string .= trim;

    my Str $array-of-basic-multiline-strings = Q:to/EOF/;
    ["""red""", """maroon""", """crimson"""]
    EOF
    $array-of-basic-multiline-strings .= trim;

    my Str $array-of-basic-multiline-strings-newlines = Q:to/EOF/;
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
    $array-of-basic-multiline-strings-newlines .= trim;

    my Str $array-of-literal-strings = Q:to/EOF/;
    ['red', 'maroon', 'crimson']
    EOF
    $array-of-literal-strings .= trim;

    my Str $array-of-literal-strings-newlines = Q:to/EOF/;
    [
        'red',
        'maroon',
        'crimson',
    ]
    EOF
    $array-of-literal-strings-newlines .= trim;

    my Str $array-of-literal-empty-strings = Q:to/EOF/;
    ['', ' ', '		']
    EOF
    $array-of-literal-empty-strings .= trim;

    my Str $array-of-literal-multiline-string = Q:to/EOF/;
    ['''red''',]
    EOF
    $array-of-literal-multiline-string .= trim;

    my Str $array-of-literal-multiline-strings = Q:to/EOF/;
    ['''red''', '''maroon''', '''crimson''']
    EOF
    $array-of-literal-multiline-strings .= trim;

    my Str $array-of-literal-multiline-strings-newlines = Q:to/EOF/;
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
    $array-of-literal-multiline-strings-newlines .= trim;

    my Str $array-of-mixed-strings = Q:to/EOF/;
    [ "first", 'second', """third""", '''fourth''', "", '', ]
    EOF
    $array-of-mixed-strings .= trim;

    my Str $array-of-difficult-strings = q:to/EOF/;
    [ "] ", " # ", '\ ', '\', '''\ ''', '''\''']
    EOF
    $array-of-difficult-strings .= trim;

    my Str $array-of-difficult-strings-leading-commas = q:to/EOF/;
    [
        "] "
        , " # "
        , '\ '
        , '\'
        , '''\ '''
        , '''\'''
    ]
    EOF
    $array-of-difficult-strings-leading-commas .= trim;

    my Config::TOML::Parser::Actions $actions .= new;
    my $match-array-of-basic-strings = Config::TOML::Parser::Grammar.parse(
        $array-of-basic-strings,
        :$actions,
        :rule<array>
    );
    my $match-array-of-basic-strings-newlines = Config::TOML::Parser::Grammar.parse(
        $array-of-basic-strings-newlines,
        :$actions,
        :rule<array>
    );
    my $match-array-of-basic-empty-strings = Config::TOML::Parser::Grammar.parse(
        $array-of-basic-empty-strings,
        :$actions,
        :rule<array>
    );
    my $match-array-of-basic-multiline-string = Config::TOML::Parser::Grammar.parse(
        $array-of-basic-multiline-string,
        :$actions,
        :rule<array>
    );
    my $match-array-of-basic-multiline-strings = Config::TOML::Parser::Grammar.parse(
        $array-of-basic-multiline-strings,
        :$actions,
        :rule<array>
    );
    my $match-array-of-basic-multiline-strings-newlines = Config::TOML::Parser::Grammar.parse(
        $array-of-basic-multiline-strings-newlines,
        :$actions,
        :rule<array>
    );
    my $match-array-of-literal-strings = Config::TOML::Parser::Grammar.parse(
        $array-of-literal-strings,
        :$actions,
        :rule<array>
    );
    my $match-array-of-literal-strings-newlines = Config::TOML::Parser::Grammar.parse(
        $array-of-literal-strings-newlines,
        :$actions,
        :rule<array>
    );
    my $match-array-of-literal-empty-strings = Config::TOML::Parser::Grammar.parse(
        $array-of-literal-empty-strings,
        :$actions,
        :rule<array>
    );
    my $match-array-of-literal-multiline-string = Config::TOML::Parser::Grammar.parse(
        $array-of-literal-multiline-string,
        :$actions,
        :rule<array>
    );
    my $match-array-of-literal-multiline-strings = Config::TOML::Parser::Grammar.parse(
        $array-of-literal-multiline-strings,
        :$actions,
        :rule<array>
    );
    my $match-array-of-literal-multiline-strings-newlines = Config::TOML::Parser::Grammar.parse(
        $array-of-literal-multiline-strings-newlines,
        :$actions,
        :rule<array>
    );
    my $match-array-of-mixed-strings = Config::TOML::Parser::Grammar.parse(
        $array-of-mixed-strings,
        :$actions,
        :rule<array>
    );
    my $match-array-of-difficult-strings = Config::TOML::Parser::Grammar.parse(
        $array-of-difficult-strings,
        :$actions,
        :rule<array>
    );
    my $match-array-of-difficult-strings-leading-commas = Config::TOML::Parser::Grammar.parse(
        $array-of-difficult-strings-leading-commas,
        :$actions,
        :rule<array>
    );

    is(
        $match-array-of-basic-strings.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($array-of-basic-strings, :rule<array>)] - 25 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of basic strings
        ┃   Success   ┃    successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-array-of-basic-strings-newlines.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse(
              $array-of-basic-strings-newlines,
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
        $match-array-of-basic-empty-strings.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse(
              $array-of-basic-empty-strings,
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
        $match-array-of-basic-multiline-string.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse(
              $array-of-basic-multiline-string,
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
        $match-array-of-basic-multiline-strings.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse(
              $array-of-basic-multiline-strings,
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
        $match-array-of-basic-multiline-strings-newlines.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse(
              $array-of-basic-multiline-strings-newlines,
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
        $match-array-of-literal-strings.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($array-of-literal-strings, :rule<array>)] - 31 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of literal strings
        ┃   Success   ┃    successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-array-of-literal-strings-newlines.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse(
              $array-of-literal-strings-newlines,
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
        $match-array-of-literal-empty-strings.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse(
              $array-of-literal-empty-strings,
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
        $match-array-of-literal-multiline-string.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse(
              $array-of-literal-multiline-string,
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
        $match-array-of-literal-multiline-strings.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse(
              $array-of-literal-multiline-strings,
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
        $match-array-of-literal-multiline-strings-newlines.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse(
              $array-of-literal-multiline-strings-newlines,
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
        $match-array-of-mixed-strings.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($array-of-mixed-strings, :rule<array>)] - 37 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of mixed strings
        ┃   Success   ┃    successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-array-of-difficult-strings.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($array-of-difficult-strings, :rule<array>)] - 38 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of difficult
        ┃   Success   ┃    strings successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-array-of-difficult-strings-leading-commas.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse(
              $array-of-difficult-strings-leading-commas,
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
        $match-array-of-basic-strings.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 40 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-array-of-basic-strings.made.WHAT
        ┃   Success   ┃        ~~ Array
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-array-of-basic-strings-newlines.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 41 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-array-of-basic-strings-newlines.made.WHAT
        ┃   Success   ┃        ~~ Array
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-array-of-basic-empty-strings.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 42 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-array-of-basic-empty-strings.made.WHAT
        ┃   Success   ┃        ~~ Array
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-array-of-basic-multiline-string.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 43 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-array-of-basic-multiline-string.made.WHAT
        ┃   Success   ┃        ~~ Array
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-array-of-basic-multiline-strings.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 44 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-array-of-basic-multiline-strings.made.WHAT
        ┃   Success   ┃        ~~ Array
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-array-of-basic-multiline-strings-newlines.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 45 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-array-of-basic-multiline-strings-newlines
        ┃   Success   ┃        .made
        ┃             ┃        .WHAT ~~ Array
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-array-of-literal-strings.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 46 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-array-of-literal-strings.made.WHAT
        ┃   Success   ┃        ~~ Array
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-array-of-literal-strings-newlines.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 47 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-array-of-literal-strings-newlines
        ┃   Success   ┃        .made
        ┃             ┃        .WHAT ~~ Array
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-array-of-literal-empty-strings.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 48 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-array-of-literal-empty-strings.made.WHAT
        ┃   Success   ┃        ~~ Array
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-array-of-literal-multiline-string.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 49 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-array-of-literal-multiline-string
        ┃   Success   ┃        .made
        ┃             ┃        .WHAT ~~ Array
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-array-of-literal-multiline-strings.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 50 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-array-of-literal-multiline-strings
        ┃   Success   ┃        .made
        ┃             ┃        .WHAT ~~ Array
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-array-of-literal-multiline-strings-newlines.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 51 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-array-of-literal-multiline-strings-newlines
        ┃   Success   ┃        .made
        ┃             ┃        .WHAT ~~ Array
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-array-of-mixed-strings.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 52 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-array-of-mixed-strings.made.WHAT
        ┃   Success   ┃        ~~ Array
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-array-of-difficult-strings.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 53 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-array-of-difficult-strings.made.WHAT
        ┃   Success   ┃        ~~ Array
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-array-of-difficult-strings-leading-commas.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 54 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-array-of-difficult-strings-leading-commas
        ┃   Success   ┃        .made
        ┃             ┃        .WHAT ~~ Array
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-array-of-basic-strings.made,
        ["red", "maroon", "crimson"],
        q:to/EOF/
        ♪ [Is expected array value?] - 55 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-array-of-basic-strings.made
        ┃   Success   ┃        ~~ ["red", "maroon", "crimson"]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-array-of-basic-strings-newlines.made,
        ["red", "maroon", "crimson"],
        q:to/EOF/
        ♪ [Is expected array value?] - 56 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-array-of-basic-strings-newlines.made
        ┃   Success   ┃        ~~ ["red", "maroon", "crimson"]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-array-of-basic-empty-strings.made,
        ["", " ", "\t\t"],
        q:to/EOF/
        ♪ [Is expected array value?] - 57 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-array-of-basic-empty-strings.made
        ┃   Success   ┃        ~~ ["", " ", "\t\t"]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-array-of-basic-multiline-string.made,
        ["red"],
        q:to/EOF/
        ♪ [Is expected array value?] - 58 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-array-of-basic-multiline-string.made
        ┃   Success   ┃        ~~ ["red"]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-array-of-basic-multiline-strings.made,
        ["red", "maroon", "crimson"],
        q:to/EOF/
        ♪ [Is expected array value?] - 59 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-array-of-basic-multiline-strings.made
        ┃   Success   ┃        ~~ ["red", "maroon", "crimson"]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    # leading whitespace in this array is because TOML parser does not
    # parse heredocs like Perl6, leading spaces on the outside edges of
    # multiline string delimiters are preserved
    is(
        $match-array-of-basic-multiline-strings-newlines.made,
        [
            "    red maroon \ncrimson\n    ",
            "    blue\n    aqua\n    turquoise\n    ",
            " brown tan\n auburn"
        ],
        q:to/EOF/
        ♪ [Is expected array value?] - 60 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-array-of-basic-multiline-strings-newlines
        ┃   Success   ┃        .made ~~ [ ... ]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-array-of-literal-strings.made,
        ["red", "maroon", "crimson"],
        q:to/EOF/
        ♪ [Is expected array value?] - 61 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-array-of-literal-strings.made
        ┃   Success   ┃        ~~ ["red", "maroon", "crimson"]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-array-of-literal-strings-newlines.made,
        ["red", "maroon", "crimson"],
        q:to/EOF/
        ♪ [Is expected array value?] - 62 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-array-of-literal-strings-newlines
        ┃   Success   ┃        .made ~~ ["red", "maroon", "crimson"]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-array-of-literal-empty-strings.made,
        ["", " ", "\t\t"],
        q:to/EOF/
        ♪ [Is expected array value?] - 63 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-array-of-literal-empty-strings.made
        ┃   Success   ┃        ~~ ["", " ", "\t\t"]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-array-of-literal-multiline-string.made,
        ["red"],
        q:to/EOF/
        ♪ [Is expected array value?] - 64 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-array-of-literal-multiline-string
        ┃   Success   ┃        .made ~~ ["red"]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-array-of-literal-multiline-strings.made,
        ["red", "maroon", "crimson"],
        q:to/EOF/
        ♪ [Is expected array value?] - 65 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-array-of-literal-multiline-strings
        ┃   Success   ┃        .made ~~ ["red", "maroon", "crimson"]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-array-of-literal-multiline-strings-newlines.made,
        [
            "    red \\\n    maroon \\\n    crimson\n    ",
            "    blue\n    aqua\n    turquoise\n    ",
            " brown tan auburn"
        ],
        q:to/EOF/
        ♪ [Is expected array value?] - 66 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-array-of-literal-multiline-strings-newlines
        ┃   Success   ┃        .made ~~ [ ... ]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-array-of-mixed-strings.made,
        ["first", "second", "third", "fourth", "", ""],
        q:to/EOF/
        ♪ [Is expected array value?] - 67 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-array-of-mixed-strings.made
        ┃   Success   ┃        ~~ ["first", "second", "third", "fourth", "", ""]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-array-of-difficult-strings.made,
        ["] ", " # ", "\\ ", "\\", "\\ ", "\\"],
        q:to/EOF/
        ♪ [Is expected array value?] - 68 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-array-of-difficult-strings.made
        ┃   Success   ┃        ~~ ["] ", " # ", "\\ ", "\\", "\\ ", "\\"]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-array-of-difficult-strings-leading-commas.made,
        ["] ", " # ", "\\ ", "\\", "\\ ", "\\"],
        q:to/EOF/
        ♪ [Is expected array value?] - 69 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-array-of-difficult-strings-leading-commas
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
    my Str $array-of-integers = '[ 8001, 8001, 8002 ]';
    my Str $array-of-integers-newlines = Q:to/EOF/;
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
    $array-of-integers-newlines .= trim;

    my Config::TOML::Parser::Actions $actions .= new;
    my $match-array-of-integers = Config::TOML::Parser::Grammar.parse(
        $array-of-integers,
        :$actions,
        :rule<array>
    );
    my $match-array-of-integers-newlines = Config::TOML::Parser::Grammar.parse(
        $array-of-integers-newlines,
        :$actions,
        :rule<array>
    );

    is(
        $match-array-of-integers.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($array-of-integers, :rule<array>)] - 70 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of integers
        ┃   Success   ┃    successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-array-of-integers-newlines.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($array-of-integers-newlines, :rule<array>)] - 71 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of integers
        ┃   Success   ┃    (with newlines) successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-array-of-integers.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 72 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-array-of-integers.made.WHAT
        ┃   Success   ┃        ~~ Array[Int]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-array-of-integers-newlines.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 73 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-array-of-integers-newlines.made.WHAT
        ┃   Success   ┃        ~~ Array
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-array-of-integers.made,
        [8001, 8001, 8002],
        q:to/EOF/
        ♪ [Is expected array value?] - 74 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-array-of-integers.made
        ┃   Success   ┃        ~~ [8001, 8001, 8002]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-array-of-integers-newlines.made,
        [99, 42, 0, -17, 1000, 5349221, 12345],
        q:to/EOF/
        ♪ [Is expected array value?] - 75 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-array-of-integers-newlines.made
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
    my Str $array-of-floats = '[ 0.0, -1.1, +2.2, -3.3, +4.4, -5.5 ]';
    my Str $array-of-floats-newlines = Q:to/EOF/;
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
    $array-of-floats-newlines .= trim;

    my Config::TOML::Parser::Actions $actions .= new;
    my $match-array-of-floats = Config::TOML::Parser::Grammar.parse(
        $array-of-floats,
        :$actions,
        :rule<array>
    );
    my $match-array-of-floats-newlines = Config::TOML::Parser::Grammar.parse(
        $array-of-floats-newlines,
        :$actions,
        :rule<array>
    );

    is(
        $match-array-of-floats.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($array-of-floats, :rule<array>)] - 76 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of floats
        ┃   Success   ┃    successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-array-of-floats-newlines.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($array-of-floats-newlines, :rule<array>)] - 77 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of floats
        ┃   Success   ┃    (with newlines) successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-array-of-floats.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 78 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-array-of-floats.made.WHAT ~~ Array
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-array-of-floats-newlines.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 79 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-array-of-floats-newlines.made.WHAT
        ┃   Success   ┃        ~~ Array
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-array-of-floats.made,
        [0.0, -1.1, 2.2, -3.3, 4.4, -5.5],
        q:to/EOF/
        ♪ [Is expected array value?] - 80 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-array-of-floats.made
        ┃   Success   ┃        ~~ [0.0, -1.1, 2.2, -3.3, 4.4, -5.5]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-array-of-floats-newlines.made,
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
        ┃             ┃  ∙ $match-array-of-floats-newlines.made.WHAT
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
    my Str $array-of-booleans = '[true,false]';
    my Str $array-of-booleans-newlines = Q:to/EOF/;
    [
        true
        , false
    ]
    EOF
    $array-of-booleans-newlines .= trim;

    my Config::TOML::Parser::Actions $actions .= new;
    my $match-array-of-booleans = Config::TOML::Parser::Grammar.parse(
        $array-of-booleans,
        :$actions,
        :rule<array>
    );
    my $match-array-of-booleans-newlines = Config::TOML::Parser::Grammar.parse(
        $array-of-booleans-newlines,
        :$actions,
        :rule<array>
    );

    is(
        $match-array-of-booleans.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($array-of-booleans, :rule<array>)] - 82 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of booleans successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-array-of-booleans-newlines.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($array-of-booleans-newlines, :rule<array>)] - 83 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of booleans
        ┃   Success   ┃    (with newlines) successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-array-of-booleans.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 84 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-array-of-booleans.made.WHAT ~~ Array
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-array-of-booleans-newlines.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 85 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-array-of-booleans-newlines.made.WHAT ~~ Array
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-array-of-booleans.made,
        [True, False],
        q:to/EOF/
        ♪ [Is expected array value?] - 86 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-array-of-booleans.made ~~ [True, False]
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-array-of-booleans-newlines.made,
        [True, False],
        q:to/EOF/
        ♪ [Is expected array value?] - 87 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-array-of-booleans-newlines.made
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
    my Str $array-of-date-times = '[1979-05-27T07:32:00Z,]';
    my Str $array-of-date-times-newlines = Q:to/EOF/;
    [
        1979-05-27T07:32:00Z,
        1979-05-27T00:32:00-07:00,
        1979-05-27T00:32:00.999999-07:00,
        1979-05-27T07:32:00,
        1979-05-27T00:32:00.999999,
        1979-05-27
    ]
    EOF
    $array-of-date-times-newlines .= trim;

    # assume UTC when local offset unspecified in TOML dates
    my Config::TOML::Parser::Actions $actions .= new(:date-local-offset(0));
    my $match-array-of-date-times = Config::TOML::Parser::Grammar.parse(
        $array-of-date-times,
        :$actions,
        :rule<array>
    );
    my $match-array-of-date-times-newlines = Config::TOML::Parser::Grammar.parse(
        $array-of-date-times-newlines,
        :$actions,
        :rule<array>
    );

    is(
        $match-array-of-date-times.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($array-of-date-times, :rule<array>)] - 88 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of datetimes
        ┃   Success   ┃    successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-array-of-date-times-newlines.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse(
              $array-of-date-times-newlines,
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
        $match-array-of-date-times.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 90 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-array-of-date-times.made.WHAT ~~ Array
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-array-of-date-times-newlines.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 91 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-array-of-date-times-newlines.made.WHAT
        ┃   Success   ┃        ~~ Array
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-array-of-date-times.made,
        ['1979-05-27T07:32:00Z'],
        q:to/EOF/
        ♪ [Is expected array value?] - 92 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-array-of-date-times.made ~~ [ ... ]
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-array-of-date-times-newlines.made,
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
        ┃             ┃  ∙ $match-array-of-date-times-newlines.made
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
    my Str $array-of-arrays = '[ [ 1, 2 ], [-3e1_000, +4.56, 5.0] ]';
    my Str $array-of-arrays-newlines = Q:to/EOF/;
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
    $array-of-arrays-newlines .= trim;
    my Str $array-of-empty-arrays = Q:to/EOF/;
    [[[[[]]]]]
    EOF
    $array-of-empty-arrays .= trim;

    my Config::TOML::Parser::Actions $actions .= new;
    my $match-array-of-arrays = Config::TOML::Parser::Grammar.parse(
        $array-of-arrays,
        :$actions,
        :rule<array>
    );
    my $match-array-of-arrays-newlines = Config::TOML::Parser::Grammar.parse(
        $array-of-arrays-newlines,
        :$actions,
        :rule<array>
    );
    my $match-array-of-empty-arrays = Config::TOML::Parser::Grammar.parse(
        $array-of-empty-arrays,
        :$actions,
        :rule<array>
    );

    is(
        $match-array-of-arrays.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($array-of-arrays, :rule<array>)] - 94 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of arrays
        ┃   Success   ┃    successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-array-of-arrays-newlines.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse(
              $array-of-arrays-newlines,
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
        $match-array-of-empty-arrays.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse(
              $array-of-empty-arrays,
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
        $match-array-of-arrays.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 97 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-array-of-arrays.made.WHAT ~~ Array
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-array-of-arrays-newlines.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 98 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-array-of-arrays-newlines.made.WHAT ~~ Array
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-array-of-empty-arrays.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 99 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-array-of-empty-arrays.made.WHAT ~~ Array
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-array-of-arrays.made,
        [[1, 2], [-Inf, 4.56, 5.0]],
        q:to/EOF/
        ♪ [Is expected array value?] - 100 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-array-of-arrays.made ~~ [ ... ]
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-array-of-arrays-newlines.made,
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
        ┃             ┃  ∙ $match-array-of-arrays-newlines.made ~~ [ ... ]
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-array-of-empty-arrays.made,
        [[[[[]]]]],
        q:to/EOF/
        ♪ [Is expected array value?] - 102 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-array-of-empty-arrays.made ~~ [ ... ]
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
    my Str $array-of-inline-tables = Q:to/EOF/;
    [ { x = 1, y = 2, z = 3 },
      { x = 7, y = 8, z = 9 },
      { x = 2, y = 4, z = 8 } ]
    EOF
    $array-of-inline-tables .= trim;

    my Config::TOML::Parser::Actions $actions .= new;
    my $match-array-of-inline-tables = Config::TOML::Parser::Grammar.parse(
        $array-of-inline-tables,
        :$actions,
        :rule<array>
    );

    is(
        $match-array-of-inline-tables.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($array-of-inline-tables, :rule<array>)] - 103 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of inline tables
        ┃   Success   ┃    successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-array-of-inline-tables.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 104 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-array-of-inline-tables.made.WHAT ~~ Array
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-array-of-inline-tables.made,
        [
            %( x => 1, y => 2, z => 3 ),
            %( x => 7, y => 8, z => 9 ),
            %( x => 2, y => 4, z => 8 )
        ],
        q:to/EOF/
        ♪ [Is expected array value?] - 105 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-array-of-inline-tables.made ~~ [ ... ]
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
    my Str $commented-array-of-mixed-strings = Q:to/EOF/;
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
    $commented-array-of-mixed-strings .= trim;
    my Str $commented-array-of-integers = Q:to/EOF/;
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
    $commented-array-of-integers .= trim;
    my Str $commented-array-of-floats = Q:to/EOF/;
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
    $commented-array-of-floats .= trim;
    my Str $commented-array-of-booleans = Q:to/EOF/;
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
    $commented-array-of-booleans .= trim;
    my Str $commented-array-of-date-times = Q:to/EOF/;
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
    $commented-array-of-date-times .= trim;
    my Str $commented-array-of-arrays = Q:to/EOF/;
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
    $commented-array-of-arrays .= trim;

    # assume UTC when local offset unspecified in TOML dates
    my Config::TOML::Parser::Actions $actions .= new(:date-local-offset(0));
    my $match-commented-array-of-mixed-strings = Config::TOML::Parser::Grammar.parse(
        $commented-array-of-mixed-strings,
        :$actions,
        :rule<array>
    );
    my $match-commented-array-of-integers = Config::TOML::Parser::Grammar.parse(
        $commented-array-of-integers,
        :$actions,
        :rule<array>
    );
    my $match-commented-array-of-floats = Config::TOML::Parser::Grammar.parse(
        $commented-array-of-floats,
        :$actions,
        :rule<array>
    );
    my $match-commented-array-of-booleans = Config::TOML::Parser::Grammar.parse(
        $commented-array-of-booleans,
        :$actions,
        :rule<array>
    );
    my $match-commented-array-of-date-times = Config::TOML::Parser::Grammar.parse(
        $commented-array-of-date-times,
        :$actions,
        :rule<array>
    );
    my $match-commented-array-of-arrays = Config::TOML::Parser::Grammar.parse(
        $commented-array-of-arrays,
        :$actions,
        :rule<array>
    );

    is(
        $match-commented-array-of-mixed-strings.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse(
              $commented-array-of-mixed-strings,
              :rule<array>
           )] - 106 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal commented array
        ┃   Success   ┃    of mixed-strings successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-commented-array-of-integers.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($commented-array-of-integers, :rule<array>)] - 107 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal commented array
        ┃   Success   ┃    of integers successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-commented-array-of-floats.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($commented-array-of-floats, :rule<array>)] - 108 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal commented array
        ┃   Success   ┃    of floats successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-commented-array-of-booleans.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($commented-array-of-booleans, :rule<array>)] - 109 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal commented array
        ┃   Success   ┃    of booleans successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-commented-array-of-date-times.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse(
              $commented-array-of-date-times,
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
        $match-commented-array-of-arrays.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($commented-array-of-arrays, :rule<array>)] - 111 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal commented array
        ┃   Success   ┃    of arrays successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-commented-array-of-mixed-strings.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 112 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-commented-array-of-mixed-strings.made.WHAT
        ┃   Success   ┃        ~~ Array
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-commented-array-of-integers.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 113 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-commented-array-of-integers.made.WHAT
        ┃   Success   ┃        ~~ Array
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-commented-array-of-floats.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 114 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-commented-array-of-floats.made.WHAT
        ┃   Success   ┃        ~~ Array
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-commented-array-of-booleans.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 115 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-commented-array-of-booleans.made.WHAT
        ┃   Success   ┃        ~~ Array
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-commented-array-of-date-times.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 116 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-commented-array-of-date-times.made.WHAT
        ┃   Success   ┃        ~~ Array
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-commented-array-of-arrays.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 117 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-commented-array-of-arrays.made.WHAT
        ┃   Success   ┃        ~~ Array
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-commented-array-of-mixed-strings.made,
        ["a", "b", "c", "d"],
        q:to/EOF/
        ♪ [Is expected array value?] - 118 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-commented-array-of-mixed-strings.made
        ┃   Success   ┃        ~~ [ ... ]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-commented-array-of-integers.made,
        [1, 2, 3],
        q:to/EOF/
        ♪ [Is expected array value?] - 119 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-commented-array-of-integers.made
        ┃   Success   ┃        ~~ [ ... ]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-commented-array-of-floats.made,
        [1.1, -2e1000, 0.0000001],
        q:to/EOF/
        ♪ [Is expected array value?] - 120 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-commented-array-of-floats.made
        ┃   Success   ┃        ~~ [ ... ]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-commented-array-of-booleans.made,
        [True, False, True],
        q:to/EOF/
        ♪ [Is expected array value?] - 121 of 123
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-commented-array-of-booleans.made
        ┃   Success   ┃        ~~ [ ... ]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-commented-array-of-date-times.made,
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
        ┃             ┃  ∙ $match-commented-array-of-date-times.made
        ┃   Success   ┃        ~~ [ ... ]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-commented-array-of-arrays.made,
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
        ┃             ┃  ∙ $match-commented-array-of-arrays.made
        ┃   Success   ┃        ~~ [ ... ]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

# end commented array grammar-actions tests }}}

# vim: ft=perl6 fdm=marker fdl=0
