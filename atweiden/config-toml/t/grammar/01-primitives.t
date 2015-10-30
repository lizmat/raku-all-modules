use v6;
use lib 'lib';
use Test;
use Config::TOML::Parser::Grammar;

plan 5;

# comment grammar tests {{{

subtest
{
    my Str $comment = '# Yeah, you can do this.';

    my $match_comment = Config::TOML::Parser::Grammar.parse(
        $comment,
        :rule<comment>
    );

    is(
        $match_comment.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($comment, :rule<comment>)] - 1 of 28
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal comment successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

# end comment grammar tests }}}
# string grammar tests {{{

subtest
{
    my Str $string_basic = Q:to/EOF/;
    "I'm a string with backslashes (\\). \"You can quote me\". Name\tJosh\nLocation\tSF.\\"
    EOF
    $string_basic .= trim;

    my Str $string_basic_backslash = Q:to/EOF/;
    "I'm a string ending with a backslash followed by a whitespace\\ "
    EOF
    $string_basic_backslash .= trim;

    my Str $string_basic_empty = Q:to/EOF/;
    ""
    EOF
    $string_basic_empty .= trim;

    my Str $string_basic_multiline = Q:to/EOF/;
    """\
    asdf	<-- tab
    \"\"\"
    \"""
    what
    """
    EOF
    $string_basic_multiline .= trim;

    my Str $string_literal = Q:to/EOF/;
    '\\\Server\X\admin$\system32\\\\\\'
    EOF
    $string_literal .= trim;

    my Str $string_literal_empty = Q:to/EOF/;
    ''
    EOF
    $string_literal_empty .= trim;

    my Str $string_literal_multiline = Q:to/EOF/;
    '''\
    asdf		<-- two tabs
    \'\'\'
    what
    '''
    EOF
    $string_literal_multiline .= trim;

    my $match_string_basic = Config::TOML::Parser::Grammar.parse(
        $string_basic,
        :rule<string_basic>
    );
    my $match_string_basic_backslash = Config::TOML::Parser::Grammar.parse(
        $string_basic_backslash,
        :rule<string_basic>
    );
    my $match_string_basic_empty = Config::TOML::Parser::Grammar.parse(
        $string_basic_empty,
        :rule<string_basic>
    );
    my $match_string_basic_multiline = Config::TOML::Parser::Grammar.parse(
        $string_basic_multiline,
        :rule<string_basic_multiline>
    );
    my $match_string_literal = Config::TOML::Parser::Grammar.parse(
        $string_literal,
        :rule<string_literal>
    );
    my $match_string_literal_empty = Config::TOML::Parser::Grammar.parse(
        $string_literal_empty,
        :rule<string_literal>
    );
    my $match_string_literal_multiline = Config::TOML::Parser::Grammar.parse(
        $string_literal_multiline,
        :rule<string_literal_multiline>
    );

    is(
        $match_string_basic.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($string_basic, :rule<string_basic>)] - 2 of 28
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses double quoted string successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match_string_basic_backslash.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse(
              $string_basic_backslash,
              :rule<string_basic>
           )] - 3 of 28
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses double quoted string successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match_string_basic_empty.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($string_basic_empty, :rule<string_basic>)] - 4 of 28
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses double quoted empty string successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match_string_basic_multiline.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse(
            $string_basic_multiline,
            :rule<string_basic_multiline>
           )] - 5 of 28
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses double quoted multiline string successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match_string_literal.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($string_literal, :rule<string_literal>)] - 6 of 28
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses single quoted string successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match_string_literal_empty.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse(
              $string_literal_empty,
              :rule<string_literal>
           )] - 7 of 28
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses single quoted empty string successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match_string_literal_multiline.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse(
              $string_literal_multiline,
              :rule<string_literal_multiline>
           )] - 8 of 28
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses single quoted multiline string
        ┃   Success   ┃    successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

# end string grammar tests }}}
# number grammar tests {{{

subtest
{
    my Str $integer_basic = '-1';
    my Str $integer_underscore = '1_000_000';
    my Str $float_basic = '-0.1';
    my Str $float_underscore = '+1_000_000_000.111_111_111';
    my Str $float_exponent = '1e1_000';
    my Str $float_exponent_underscore = '987_654.321e1_234_567';

    my $match_integer_basic = Config::TOML::Parser::Grammar.parse(
        $integer_basic,
        :rule<integer>
    );
    my $match_integer_underscore = Config::TOML::Parser::Grammar.parse(
        $integer_underscore,
        :rule<integer>
    );
    my $match_float_basic = Config::TOML::Parser::Grammar.parse(
        $float_basic,
        :rule<float>
    );
    my $match_float_underscore = Config::TOML::Parser::Grammar.parse(
        $float_underscore,
        :rule<float>
    );
    my $match_float_exponent = Config::TOML::Parser::Grammar.parse(
        $float_exponent,
        :rule<float>
    );
    my $match_float_exponent_underscore = Config::TOML::Parser::Grammar.parse(
        $float_exponent_underscore,
        :rule<float>
    );

    is(
        $match_integer_basic.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($integer_basic, :rule<integer>)] - 9 of 28
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal integer successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match_integer_underscore.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($integer_underscore, :rule<integer>)] - 10 of 28
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal integer (with
        ┃   Success   ┃    underscores) successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match_float_basic.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($float_basic, :rule<float>)] - 11 of 28
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal float successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match_float_underscore.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($float_underscore, :rule<float>)] - 12 of 28
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal float (with underscores)
        ┃   Success   ┃    successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match_float_exponent.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($float_exponent, :rule<float>)] - 13 of 28
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal float (with exponent)
        ┃   Success   ┃    successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match_float_exponent_underscore.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($float_exponent_underscore, :rule<float>)] - 14 of 28
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal float (with exponent
        ┃   Success   ┃    and underscores) successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

# end number grammar tests }}}
# boolean grammar tests {{{

subtest
{
    my Str $boolean_true = 'true';
    my Str $boolean_false = 'false';

    my $match_boolean_true = Config::TOML::Parser::Grammar.parse(
        $boolean_true,
        :rule<boolean>
    );
    my $match_boolean_false = Config::TOML::Parser::Grammar.parse(
        $boolean_false,
        :rule<boolean>
    );

    is(
        $match_boolean_true.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($boolean_true, :rule<boolean>)] - 15 of 28
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal true successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match_boolean_false.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($boolean_false, :rule<boolean>)] - 16 of 28
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal false successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

# end boolean grammar tests }}}
# datetime grammar tests {{{

subtest
{
    my Str $date1 = '1979-05-27T07:32:00Z';
    my Str $date2 = '1979-05-27T00:32:00-07:00';
    my Str $date3 = '1979-05-27T00:32:00.999999-07:00';
    my Str $date4 = '1979-05-27T07:32:00';
    my Str $date5 = '1979-05-27T00:32:00.999999';
    my Str $date6 = '1979-05-27';

    # *_proto vars test for match against proto token date
    my $match_date1 = Config::TOML::Parser::Grammar.parse(
        $date1,
        :rule<date_time>
    );
    my $match_date1_proto = Config::TOML::Parser::Grammar.parse(
        $date1,
        :rule<date>
    );
    my $match_date2 = Config::TOML::Parser::Grammar.parse(
        $date2,
        :rule<date_time>
    );
    my $match_date2_proto = Config::TOML::Parser::Grammar.parse(
        $date2,
        :rule<date>
    );
    my $match_date3 = Config::TOML::Parser::Grammar.parse(
        $date3,
        :rule<date_time>
    );
    my $match_date3_proto = Config::TOML::Parser::Grammar.parse(
        $date3,
        :rule<date>
    );
    my $match_date4 = Config::TOML::Parser::Grammar.parse(
        $date4,
        :rule<date_time_omit_local_offset>
    );
    my $match_date4_proto = Config::TOML::Parser::Grammar.parse(
        $date4,
        :rule<date>
    );
    my $match_date5 = Config::TOML::Parser::Grammar.parse(
        $date5,
        :rule<date_time_omit_local_offset>
    );
    my $match_date5_proto = Config::TOML::Parser::Grammar.parse(
        $date5,
        :rule<date>
    );
    my $match_date6 = Config::TOML::Parser::Grammar.parse(
        $date6,
        :rule<full_date>
    );
    my $match_date6_proto = Config::TOML::Parser::Grammar.parse(
        $date6,
        :rule<date>
    );

    is(
        $match_date1.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($date1, :rule<date_time>)] - 17 of 28
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal datetime successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_date1_proto.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($date1, :rule<date>)] - 18 of 28
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal datetime successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_date2.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($date2, :rule<date_time>)] - 19 of 28
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal datetime successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_date2_proto.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($date2, :rule<date>)] - 20 of 28
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal datetime successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_date3.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($date3, :rule<date_time>)] - 21 of 28
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal datetime successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_date3_proto.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($date3, :rule<date>)] - 22 of 28
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal datetime successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_date4.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse(
               $date4,
               :rule<date_time_omit_local_offset>
           )] - 23 of 28
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal datetime (omit local offset)
        ┃   Success   ┃    successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_date4_proto.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($date4, :rule<date>)] - 24 of 28
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal datetime (omit local offset)
        ┃   Success   ┃    successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_date5.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse(
               $date5,
               :rule<date_time_omit_local_offset>
           )] - 25 of 28
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal datetime (omit local offset)
        ┃   Success   ┃    successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_date5_proto.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($date5, :rule<date>)] - 26 of 28
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal datetime (omit local offset)
        ┃   Success   ┃    successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_date6.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($date6, :rule<full_date>)] - 27 of 28
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal datetime (omit local offset
        ┃   Success   ┃    and time) successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_date6_proto.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($date6, :rule<date>)] - 28 of 28
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal datetime (omit local offset
        ┃   Success   ┃    and time) successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

# end datetime grammar tests }}}

# vim: ft=perl6 fdm=marker fdl=0
