use v6;
use lib 'lib';
use Test;
use Config::TOML::Parser::Actions;
use Config::TOML::Parser::Grammar;

plan(1);

# commented inline table grammar tests {{{

subtest({
    my Str $commented-inline-table-difficult = Q:to/EOF/.trim;
    {# this is ok 1
        # this is ok 2
        # this is ok 3
        array_of_arrays = [# this is ok 4
            # this is ok 5
            # this is ok 6
            [# this is ok 7
                # this is ok 8
                'a', # this is ok 9
                # this is ok 10
                "b",# this is ok 11
                # this is ok 12
                '''c'''# this is ok 13
                # this is ok 14
                , """d"""# this is ok 15
                # this is ok 16
                # this is ok 17
                # this is ok 18
            ]# this is ok 19
            # this is ok 20
            # this is ok 21
            , # this is ok 22
            [# this is ok 23
                # this is ok 24
                [ [ 1, 2 ], [3, 4, 5] ], # this is ok 25
                [ [ 1, 2 ], ["a", "b", "c"] ],# this is ok 26
                [# this is ok 27
                    # this is ok 28
                    [ # this is ok 29
                        # this is ok 30
                        [#this is ok 31
                            # this is ok 32
                            # this is ok 33
                            '''#this is not a comment
                            line one # this is not a comment
                            line two # this is not a comment
                            line three # this is not a comment
                            ''',# this is ok 34
                            # this is ok 35
                            # this is ok 36
                            """
                            line four
                            line five
                            line six
                            """ # this is ok 37
                            # this is ok 38
                            # this is ok 39
                        ], # this is ok 40
                        [# this is ok 41
                            # this is ok 42
                            # this is ok 43
                            '''
                            line seven
                            line eight
                            line nine
                            ''', # this is ok 44
                            # this is ok 45
                            """
                            line ten
                            line eleven
                            line twelve
                            """#this is ok 46
                            # this is ok 47
                            # this is ok 48
                            # this is ok 49
                        ],# this is ok 50
                    # this is ok 51
                    # this is ok 52
                    # this is ok 53
                    ], # this is ok 54
                    # this is ok 55
                    # this is ok 56
                    [# this is ok 57
                        3,# this is ok 58
                        6,# this is ok 59
                        9# this is ok 60
                    ]# this is ok 61
                ]# this is ok 62
                # this is ok 63
                # this is ok 64
                # this is ok 65
            ]# this is ok 66
            # this is ok 67
            # this is ok 68
        ], # this is ok 69
        # this is ok 70
        # this is ok 71
        "diff\"i\\ \"cult\"?#'\\'" = true, # this is ok 72
        # this is ok 73
        # this is ok 74
        # date_times = {# this is ok 75
        #     # this is ok 76
        #     date1 = 1979-05-27T07:32:00Z, # this is ok 77
        #     date2 = 1979-05-27T00:32:00-07:00,# this is ok 78
        #     # date3 = 1979-05-27T00:32:00.999999-07:00,# this is ok 79
        #     # this is ok 80
        #     1979-05-27 = [1979-05-27T07:32:00Z,# this is ok 81
        #         1979-05-27T00:32:00-07:00,# this is ok 82
        #         # 1979-05-27T00:32:00.999999-07:00,
        #     ]# this is ok 83
        # }# this is ok 84
        # this is ok 85
        # , # this is ok 86
        empty_array_of_arrays = [[[[[[[[]]]]]]]]# this is ok 87
        # this is ok 88
    # this is ok 89
    }
    EOF

    my Config::TOML::Parser::Actions $actions .= new;
    my $match-commented-inline-table-difficult =
        Config::TOML::Parser::Grammar.parse(
            $commented-inline-table-difficult,
            :$actions,
            :rule<table-inline>
        );

    is(
        $match-commented-inline-table-difficult.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse(
              $commented-inline-table-difficult,
              :rule<table-inline>
           )] - 1 of 3
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal commented inline
        ┃   Success   ┃    table successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-commented-inline-table-difficult.made.WHAT,
        Hash,
        q:to/EOF/
        ♪ [Is inline table?] - 2 of 3
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-commented-inline-table-difficult.made.WHAT
        ┃   Success   ┃        ~~ Array
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-commented-inline-table-difficult.made,
        {
            :array_of_arrays(
                [
                    ["a", "b", "c", "d"],
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
                                ["#this is not a comment\n                        line one # this is not a comment\n                        line two # this is not a comment\n                        line three # this is not a comment\n                        ", "                        line four\n                        line five\n                        line six\n                        "],
                                ["                        line seven\n                        line eight\n                        line nine\n                        ", "                        line ten\n                        line eleven\n                        line twelve\n                        "]
                            ],
                            [3, 6, 9]
                        ]
                    ]
                ]
            ),
            "diff\"i\\ \"cult\"?#'\\'" => Bool::True,
            :empty_array_of_arrays([[[[[[[[],],],],],],],])
        },
        q:to/EOF/
        ♪ [Is expected inline table value?] - 3 of 3
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-commented-inline-table-difficult.made
        ┃   Success   ┃        ~~ [ ... ]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
});

# end commented inline table grammar tests }}}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
