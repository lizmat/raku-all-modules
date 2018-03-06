use v6;
use lib 'lib';
use Test;
use Config::TOML::Parser::Grammar;

plan(9);

# empty array grammar tests {{{

subtest({
    my Str $empty-array = '[]';
    my Str $empty-array-space = '[ ]';
    my Str $empty-array-spaces = '[   ]';
    my Str $empty-array-tab = '[	]';
    my Str $empty-array-tabs = '[			]';
    my Str $empty-array-newline = Q:to/EOF/.trim;
    [
    ]
    EOF
    my Str $empty-array-newlines = Q:to/EOF/.trim;
    [


    ]
    EOF
    my Str $empty-array-newlines-tabbed = Q:to/EOF/.trim;
    [


		]
    EOF

    my $match-empty-array =
        Config::TOML::Parser::Grammar.parse(
            $empty-array,
            :rule<array>
        );
    my $match-empty-array-space =
        Config::TOML::Parser::Grammar.parse(
            $empty-array-space,
            :rule<array>
        );
    my $match-empty-array-spaces =
        Config::TOML::Parser::Grammar.parse(
            $empty-array-spaces,
            :rule<array>
        );
    my $match-empty-array-tab =
        Config::TOML::Parser::Grammar.parse(
            $empty-array-tab,
            :rule<array>
        );
    my $match-empty-array-tabs =
        Config::TOML::Parser::Grammar.parse(
            $empty-array-tabs,
            :rule<array>
        );
    my $match-empty-array-newline =
        Config::TOML::Parser::Grammar.parse(
            $empty-array-newline,
            :rule<array>
        );
    my $match-empty-array-newlines =
        Config::TOML::Parser::Grammar.parse(
            $empty-array-newlines,
            :rule<array>
        );
    my $match-empty-array-newlines-tabbed =
        Config::TOML::Parser::Grammar.parse(
            $empty-array-newlines-tabbed,
            :rule<array>
        );

    is(
        $match-empty-array.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($empty-array, :rule<array>)] - 1 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal empty array successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-empty-array-space.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($empty-array-space, :rule<array>)] - 2 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal empty array (with
        ┃   Success   ┃    single space) successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-empty-array-spaces.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($empty-array-spaces, :rule<array>)] - 3 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal empty array (with
        ┃   Success   ┃    spaces) successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-empty-array-tab.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($empty-array-tab, :rule<array>)] - 4 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal empty array (with
        ┃   Success   ┃    single tab) successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-empty-array-tabs.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($empty-array-tabs, :rule<array>)] - 5 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal empty array (with
        ┃   Success   ┃    tabs) successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-empty-array-newline.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($empty-array-newline, :rule<array>)] - 6 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal empty array (with
        ┃   Success   ┃    single newline) successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-empty-array-newlines.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($empty-array-newlines, :rule<array>)] - 7 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal empty array (with
        ┃   Success   ┃    newlines) successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-empty-array-newlines-tabbed.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($empty-array-newlines-tabbed, :rule<array>)] - 8 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal empty array (with
        ┃   Success   ┃    newlines and tab) successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
});

# end empty array grammar tests }}}
# array of strings grammar tests {{{

subtest({
    my Str $array-of-basic-strings = Q:to/EOF/.trim;
    ["red", "maroon", "crimson"]
    EOF

    my Str $array-of-basic-strings-newlines = Q:to/EOF/.trim;
    [
        "red",
        "maroon",
        "crimson",
    ]
    EOF

    my Str $array-of-basic-empty-strings = Q:to/EOF/.trim;
    ["", " ", "		"]
    EOF

    my Str $array-of-basic-multiline-string = Q:to/EOF/.trim;
    ["""red""",]
    EOF

    my Str $array-of-basic-multiline-strings = Q:to/EOF/.trim;
    ["""red""", """maroon""", """crimson"""]
    EOF

    my Str $array-of-basic-multiline-strings-newlines = Q:to/EOF/.trim;
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

    my Str $array-of-literal-strings = Q:to/EOF/.trim;
    ['red', 'maroon', 'crimson']
    EOF

    my Str $array-of-literal-strings-newlines = Q:to/EOF/.trim;
    [
        'red',
        'maroon',
        'crimson',
    ]
    EOF

    my Str $array-of-literal-empty-strings = Q:to/EOF/.trim;
    ['', ' ', '		']
    EOF

    my Str $array-of-literal-multiline-string = Q:to/EOF/.trim;
    ['''red''',]
    EOF

    my Str $array-of-literal-multiline-strings = Q:to/EOF/.trim;
    ['''red''', '''maroon''', '''crimson''']
    EOF

    my Str $array-of-literal-multiline-strings-newlines = Q:to/EOF/.trim;
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

    my Str $array-of-mixed-strings = Q:to/EOF/.trim;
    [ "first", 'second', """third""", '''fourth''', "", '', ]
    EOF

    my Str $array-of-difficult-strings = q:to/EOF/.trim;
    [ "] ", " # ", '\ ', '\', '''\ ''', '''\''']
    EOF

    my Str $array-of-difficult-strings-leading-commas = q:to/EOF/.trim;
    [
        "] "
        , " # "
        , '\ '
        , '\'
        , '''\ '''
        , '''\'''
    ]
    EOF

    my $match-array-of-basic-strings =
        Config::TOML::Parser::Grammar.parse(
            $array-of-basic-strings,
            :rule<array>
        );
    my $match-array-of-basic-strings-newlines =
        Config::TOML::Parser::Grammar.parse(
            $array-of-basic-strings-newlines,
            :rule<array>
        );
    my $match-array-of-basic-empty-strings =
        Config::TOML::Parser::Grammar.parse(
            $array-of-basic-empty-strings,
            :rule<array>
        );
    my $match-array-of-basic-multiline-string =
        Config::TOML::Parser::Grammar.parse(
            $array-of-basic-multiline-string,
            :rule<array>
        );
    my $match-array-of-basic-multiline-strings =
        Config::TOML::Parser::Grammar.parse(
            $array-of-basic-multiline-strings,
            :rule<array>
        );
    my $match-array-of-basic-multiline-strings-newlines =
        Config::TOML::Parser::Grammar.parse(
            $array-of-basic-multiline-strings-newlines,
            :rule<array>
        );
    my $match-array-of-literal-strings =
        Config::TOML::Parser::Grammar.parse(
            $array-of-literal-strings,
            :rule<array>
        );
    my $match-array-of-literal-strings-newlines =
        Config::TOML::Parser::Grammar.parse(
            $array-of-literal-strings-newlines,
            :rule<array>
        );
    my $match-array-of-literal-empty-strings =
        Config::TOML::Parser::Grammar.parse(
            $array-of-literal-empty-strings,
            :rule<array>
        );
    my $match-array-of-literal-multiline-string =
        Config::TOML::Parser::Grammar.parse(
            $array-of-literal-multiline-string,
            :rule<array>
        );
    my $match-array-of-literal-multiline-strings =
        Config::TOML::Parser::Grammar.parse(
            $array-of-literal-multiline-strings,
            :rule<array>
        );
    my $match-array-of-literal-multiline-strings-newlines =
        Config::TOML::Parser::Grammar.parse(
            $array-of-literal-multiline-strings-newlines,
            :rule<array>
        );
    my $match-array-of-mixed-strings =
        Config::TOML::Parser::Grammar.parse(
            $array-of-mixed-strings,
            :rule<array>
        );
    my $match-array-of-difficult-strings =
        Config::TOML::Parser::Grammar.parse(
            $array-of-difficult-strings,
            :rule<array>
        );
    my $match-array-of-difficult-strings-leading-commas =
        Config::TOML::Parser::Grammar.parse(
            $array-of-difficult-strings-leading-commas,
            :rule<array>
        );

    is(
        $match-array-of-basic-strings.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($array-of-basic-strings, :rule<array>)] - 9 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of basic strings
        ┃   Success   ┃    successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-array-of-basic-strings-newlines.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse(
              $array-of-basic-strings-newlines,
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
        $match-array-of-basic-empty-strings.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse(
              $array-of-basic-empty-strings,
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
        $match-array-of-basic-multiline-string.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse(
              $array-of-basic-multiline-string,
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
        $match-array-of-basic-multiline-strings.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse(
              $array-of-basic-multiline-strings,
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
        $match-array-of-basic-multiline-strings-newlines.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse(
              $array-of-basic-multiline-strings-newlines,
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
        $match-array-of-literal-strings.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($array-of-literal-strings, :rule<array>)] - 15 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of literal strings
        ┃   Success   ┃    successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-array-of-literal-strings-newlines.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse(
              $array-of-literal-strings-newlines,
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
        $match-array-of-literal-empty-strings.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse(
              $array-of-literal-empty-strings,
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
        $match-array-of-literal-multiline-string.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse(
              $array-of-literal-multiline-string,
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
        $match-array-of-literal-multiline-strings.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse(
              $array-of-literal-multiline-strings,
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
        $match-array-of-literal-multiline-strings-newlines.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse(
              $array-of-literal-multiline-strings-newlines,
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
        $match-array-of-mixed-strings.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($array-of-mixed-strings, :rule<array>)] - 21 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of mixed strings
        ┃   Success   ┃    successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-array-of-difficult-strings.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($array-of-difficult-strings, :rule<array>)] - 22 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of difficult
        ┃   Success   ┃    strings successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-array-of-difficult-strings-leading-commas.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse(
              $array-of-difficult-strings-leading-commas,
              :rule<array>
           )] - 23 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of difficult
        ┃   Success   ┃    strings (with leading commas) successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
});

# end array of strings grammar tests }}}
# array of integers grammar tests {{{

subtest({
    my Str $array-of-integers = '[ 8001, 8001, 8002 ]';
    my Str $array-of-integers-newlines = Q:to/EOF/.trim;
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

    my $match-array-of-integers =
        Config::TOML::Parser::Grammar.parse(
            $array-of-integers,
            :rule<array>
        );
    my $match-array-of-integers-newlines =
        Config::TOML::Parser::Grammar.parse(
            $array-of-integers-newlines,
            :rule<array>
        );

    is(
        $match-array-of-integers.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($array-of-integers, :rule<array>)] - 24 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of integers
        ┃   Success   ┃    successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-array-of-integers-newlines.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($array-of-integers-newlines, :rule<array>)] - 25 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of integers
        ┃   Success   ┃    (with newlines) successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
});

# end array of integers grammar tests }}}
# array of floats grammar tests {{{

subtest({
    my Str $array-of-floats = '[ 0.0, -1.1, +2.2, -3.3, +4.4, -5.5 ]';
    my Str $array-of-floats-newlines = Q:to/EOF/.trim;
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

    my $match-array-of-floats =
        Config::TOML::Parser::Grammar.parse(
            $array-of-floats,
            :rule<array>
        );
    my $match-array-of-floats-newlines =
        Config::TOML::Parser::Grammar.parse(
            $array-of-floats-newlines,
            :rule<array>
        );

    is(
        $match-array-of-floats.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($array-of-floats, :rule<array>)] - 26 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of floats
        ┃   Success   ┃    successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-array-of-floats-newlines.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($array-of-floats-newlines, :rule<array>)] - 27 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of floats
        ┃   Success   ┃    (with newlines) successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
});

# end array of floats grammar tests }}}
# array of booleans grammar tests {{{

subtest({
    my Str $array-of-booleans = '[true,false]';
    my Str $array-of-booleans-newlines = Q:to/EOF/.trim;
    [
        true
        , false
    ]
    EOF

    my $match-array-of-booleans =
        Config::TOML::Parser::Grammar.parse(
            $array-of-booleans,
            :rule<array>
        );
    my $match-array-of-booleans-newlines =
        Config::TOML::Parser::Grammar.parse(
            $array-of-booleans-newlines,
            :rule<array>
        );

    is(
        $match-array-of-booleans.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($array-of-booleans, :rule<array>)] - 28 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of booleans successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-array-of-booleans-newlines.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($array-of-booleans-newlines, :rule<array>)] - 29 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of booleans
        ┃   Success   ┃    (with newlines) successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
});

# end array of booleans grammar tests }}}
# array of datetimes grammar tests {{{

subtest({
    my Str $array-of-date-times = '[1979-05-27T07:32:00Z,]';
    my Str $array-of-date-times-newlines = Q:to/EOF/.trim;
    [
        1979-05-27T07:32:00Z,
        1979-05-27T00:32:00-07:00,
        1979-05-27T00:32:00.999999-07:00
    ]
    EOF

    my $match-array-of-date-times =
        Config::TOML::Parser::Grammar.parse(
            $array-of-date-times,
            :rule<array>
        );
    my $match-array-of-date-times-newlines =
        Config::TOML::Parser::Grammar.parse(
            $array-of-date-times-newlines,
            :rule<array>
        );

    is(
        $match-array-of-date-times.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($array-of-date-times, :rule<array>)] - 30 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of datetimes
        ┃   Success   ┃    successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-array-of-date-times-newlines.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse(
              $array-of-date-times-newlines,
              :rule<array>
           )] - 31 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of datetimes
        ┃   Success   ┃    (with newlines) successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
});

# end array of datetimes grammar tests }}}
# array of arrays grammar tests {{{

subtest({
    my Str $array-of-arrays = '[ [ 1, 2 ], [-3e1_000, +4.56, 5.0] ]';
    my Str $array-of-arrays-newlines = Q:to/EOF/.trim;
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

    my Str $array-of-empty-arrays = Q:to/EOF/.trim;
    [[[[[]]]]]
    EOF

    my $match-array-of-arrays =
        Config::TOML::Parser::Grammar.parse(
            $array-of-arrays,
            :rule<array>
        );
    my $match-array-of-arrays-newlines =
        Config::TOML::Parser::Grammar.parse(
            $array-of-arrays-newlines,
            :rule<array>
        );
    my $match-array-of-empty-arrays =
        Config::TOML::Parser::Grammar.parse(
            $array-of-empty-arrays,
            :rule<array>
        );

    is(
        $match-array-of-arrays.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($array-of-arrays, :rule<array>)] - 32 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of arrays
        ┃   Success   ┃    successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-array-of-arrays-newlines.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse(
              $array-of-arrays-newlines,
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
        $match-array-of-empty-arrays.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse(
              $array-of-empty-arrays,
              :rule<array>
           )] - 34 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of arrays
        ┃   Success   ┃    (with newlines) successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
});

# end array of arrays grammar tests }}}
# array of inline tables grammar tests {{{

subtest({
    my Str $array-of-inline-tables = Q:to/EOF/.trim;
    [ { x = 1, y = 2, z = 3 },
      { x = 7, y = 8, z = 9 },
      { x = 2, y = 4, z = 8 } ]
    EOF

    my $match-array-of-inline-tables =
        Config::TOML::Parser::Grammar.parse(
            $array-of-inline-tables,
            :rule<array>
        );

    is(
        $match-array-of-inline-tables.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($array-of-inline-tables, :rule<array>)] - 35 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal array of inline tables
        ┃   Success   ┃    successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
});

# end array of inline tables grammar tests }}}
# commented array grammar tests {{{

subtest({
    my Str $commented-array-of-mixed-strings = Q:to/EOF/.trim;
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

    my Str $commented-array-of-integers = Q:to/EOF/.trim;
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

    my Str $commented-array-of-floats = Q:to/EOF/.trim;
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

    my Str $commented-array-of-booleans = Q:to/EOF/.trim;
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

    my Str $commented-array-of-date-times = Q:to/EOF/.trim;
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

    my Str $commented-array-of-arrays = Q:to/EOF/.trim;
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

    my $match-commented-array-of-mixed-strings =
        Config::TOML::Parser::Grammar.parse(
            $commented-array-of-mixed-strings,
            :rule<array>
        );
    my $match-commented-array-of-integers =
        Config::TOML::Parser::Grammar.parse(
            $commented-array-of-integers,
            :rule<array>
        );
    my $match-commented-array-of-floats =
        Config::TOML::Parser::Grammar.parse(
            $commented-array-of-floats,
            :rule<array>
        );
    my $match-commented-array-of-booleans =
        Config::TOML::Parser::Grammar.parse(
            $commented-array-of-booleans,
            :rule<array>
        );
    my $match-commented-array-of-date-times =
        Config::TOML::Parser::Grammar.parse(
            $commented-array-of-date-times,
            :rule<array>
        );
    my $match-commented-array-of-arrays =
        Config::TOML::Parser::Grammar.parse(
            $commented-array-of-arrays,
            :rule<array>
        );

    is(
        $match-commented-array-of-mixed-strings.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse(
              $commented-array-of-mixed-strings,
              :rule<array>
           )] - 36 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal commented array
        ┃   Success   ┃    of mixed-strings successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-commented-array-of-integers.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($commented-array-of-integers, :rule<array>)] - 37 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal commented array
        ┃   Success   ┃    of integers successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-commented-array-of-floats.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($commented-array-of-floats, :rule<array>)] - 38 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal commented array
        ┃   Success   ┃    of floats successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-commented-array-of-booleans.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($commented-array-of-booleans, :rule<array>)] - 39 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal commented array
        ┃   Success   ┃    of booleans successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-commented-array-of-date-times.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse(
              $commented-array-of-date-times,
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
        $match-commented-array-of-arrays.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($commented-array-of-arrays, :rule<array>)] - 41 of 41
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal commented array
        ┃   Success   ┃    of arrays successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
});

# end commented array grammar tests }}}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
