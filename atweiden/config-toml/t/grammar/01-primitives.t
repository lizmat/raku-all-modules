use v6;
use lib 'lib';
use Test;
use Config::TOML::Parser::Grammar;

plan 5;

# comment grammar tests {{{

subtest
{
    my Str $comment = '# Yeah, you can do this.';

    my $match-comment = Config::TOML::Parser::Grammar.parse(
        $comment,
        :rule<comment>
    );

    is(
        $match-comment.WHAT,
        Config::TOML::Parser::Grammar,
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
    my Str $string-basic = Q:to/EOF/;
    "I'm a string with backslashes (\\). \"You can quote me\". Name\tJosh\nLocation\tSF.\\"
    EOF
    $string-basic .= trim;

    my Str $string-basic-backslash = Q:to/EOF/;
    "I'm a string ending with a backslash followed by a whitespace\\ "
    EOF
    $string-basic-backslash .= trim;

    my Str $string-basic-empty = Q:to/EOF/;
    ""
    EOF
    $string-basic-empty .= trim;

    my Str $string-basic-multiline = Q:to/EOF/;
    """\
    asdf	<-- tab
    \"\"\"
    \"""
    what
    """
    EOF
    $string-basic-multiline .= trim;

    my Str $string-literal = Q:to/EOF/;
    '\\\Server\X\admin$\system32\\\\\\'
    EOF
    $string-literal .= trim;

    my Str $string-literal-empty = Q:to/EOF/;
    ''
    EOF
    $string-literal-empty .= trim;

    my Str $string-literal-multiline = Q:to/EOF/;
    '''\
    asdf		<-- two tabs
    \'\'\'
    what
    '''
    EOF
    $string-literal-multiline .= trim;

    my $match-string-basic = Config::TOML::Parser::Grammar.parse(
        $string-basic,
        :rule<string-basic>
    );
    my $match-string-basic-backslash = Config::TOML::Parser::Grammar.parse(
        $string-basic-backslash,
        :rule<string-basic>
    );
    my $match-string-basic-empty = Config::TOML::Parser::Grammar.parse(
        $string-basic-empty,
        :rule<string-basic>
    );
    my $match-string-basic-multiline = Config::TOML::Parser::Grammar.parse(
        $string-basic-multiline,
        :rule<string-basic-multiline>
    );
    my $match-string-literal = Config::TOML::Parser::Grammar.parse(
        $string-literal,
        :rule<string-literal>
    );
    my $match-string-literal-empty = Config::TOML::Parser::Grammar.parse(
        $string-literal-empty,
        :rule<string-literal>
    );
    my $match-string-literal-multiline = Config::TOML::Parser::Grammar.parse(
        $string-literal-multiline,
        :rule<string-literal-multiline>
    );

    is(
        $match-string-basic.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($string-basic, :rule<string-basic>)] - 2 of 28
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses double quoted string successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-string-basic-backslash.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse(
              $string-basic-backslash,
              :rule<string-basic>
           )] - 3 of 28
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses double quoted string successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-string-basic-empty.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($string-basic-empty, :rule<string-basic>)] - 4 of 28
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses double quoted empty string successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-string-basic-multiline.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse(
            $string-basic-multiline,
            :rule<string-basic-multiline>
           )] - 5 of 28
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses double quoted multiline string successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-string-literal.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($string-literal, :rule<string-literal>)] - 6 of 28
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses single quoted string successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-string-literal-empty.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse(
              $string-literal-empty,
              :rule<string-literal>
           )] - 7 of 28
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses single quoted empty string successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-string-literal-multiline.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse(
              $string-literal-multiline,
              :rule<string-literal-multiline>
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
    my Str $integer-basic = '-1';
    my Str $integer-underscore = '1_000_000';
    my Str $float-basic = '-0.1';
    my Str $float-underscore = '+1_000_000_000.111_111_111';
    my Str $float-exponent = '1e1_000';
    my Str $float-exponent-underscore = '987_654.321e1_234_567';

    my $match-integer-basic = Config::TOML::Parser::Grammar.parse(
        $integer-basic,
        :rule<integer>
    );
    my $match-integer-underscore = Config::TOML::Parser::Grammar.parse(
        $integer-underscore,
        :rule<integer>
    );
    my $match-float-basic = Config::TOML::Parser::Grammar.parse(
        $float-basic,
        :rule<float>
    );
    my $match-float-underscore = Config::TOML::Parser::Grammar.parse(
        $float-underscore,
        :rule<float>
    );
    my $match-float-exponent = Config::TOML::Parser::Grammar.parse(
        $float-exponent,
        :rule<float>
    );
    my $match-float-exponent-underscore = Config::TOML::Parser::Grammar.parse(
        $float-exponent-underscore,
        :rule<float>
    );

    is(
        $match-integer-basic.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($integer-basic, :rule<integer>)] - 9 of 28
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal integer successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-integer-underscore.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($integer-underscore, :rule<integer>)] - 10 of 28
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal integer (with
        ┃   Success   ┃    underscores) successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-float-basic.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($float-basic, :rule<float>)] - 11 of 28
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal float successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-float-underscore.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($float-underscore, :rule<float>)] - 12 of 28
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal float (with underscores)
        ┃   Success   ┃    successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-float-exponent.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($float-exponent, :rule<float>)] - 13 of 28
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal float (with exponent)
        ┃   Success   ┃    successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-float-exponent-underscore.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($float-exponent-underscore, :rule<float>)] - 14 of 28
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
    my Str $boolean-true = 'true';
    my Str $boolean-false = 'false';

    my $match-boolean-true = Config::TOML::Parser::Grammar.parse(
        $boolean-true,
        :rule<boolean>
    );
    my $match-boolean-false = Config::TOML::Parser::Grammar.parse(
        $boolean-false,
        :rule<boolean>
    );

    is(
        $match-boolean-true.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($boolean-true, :rule<boolean>)] - 15 of 28
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal true successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-boolean-false.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($boolean-false, :rule<boolean>)] - 16 of 28
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

    # *-proto vars test for match against proto token date
    my $match-date1 = Config::TOML::Parser::Grammar.parse(
        $date1,
        :rule<date-time>
    );
    my $match-date1-proto = Config::TOML::Parser::Grammar.parse(
        $date1,
        :rule<date>
    );
    my $match-date2 = Config::TOML::Parser::Grammar.parse(
        $date2,
        :rule<date-time>
    );
    my $match-date2-proto = Config::TOML::Parser::Grammar.parse(
        $date2,
        :rule<date>
    );
    my $match-date3 = Config::TOML::Parser::Grammar.parse(
        $date3,
        :rule<date-time>
    );
    my $match-date3-proto = Config::TOML::Parser::Grammar.parse(
        $date3,
        :rule<date>
    );
    my $match-date4 = Config::TOML::Parser::Grammar.parse(
        $date4,
        :rule<date-time-omit-local-offset>
    );
    my $match-date4-proto = Config::TOML::Parser::Grammar.parse(
        $date4,
        :rule<date>
    );
    my $match-date5 = Config::TOML::Parser::Grammar.parse(
        $date5,
        :rule<date-time-omit-local-offset>
    );
    my $match-date5-proto = Config::TOML::Parser::Grammar.parse(
        $date5,
        :rule<date>
    );
    my $match-date6 = Config::TOML::Parser::Grammar.parse(
        $date6,
        :rule<full-date>
    );
    my $match-date6-proto = Config::TOML::Parser::Grammar.parse(
        $date6,
        :rule<date>
    );

    is(
        $match-date1.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($date1, :rule<date-time>)] - 17 of 28
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal datetime successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-date1-proto.WHAT,
        Config::TOML::Parser::Grammar,
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
        $match-date2.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($date2, :rule<date-time>)] - 19 of 28
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal datetime successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-date2-proto.WHAT,
        Config::TOML::Parser::Grammar,
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
        $match-date3.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($date3, :rule<date-time>)] - 21 of 28
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal datetime successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-date3-proto.WHAT,
        Config::TOML::Parser::Grammar,
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
        $match-date4.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse(
               $date4,
               :rule<date-time-omit-local-offset>
           )] - 23 of 28
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal datetime (omit local offset)
        ┃   Success   ┃    successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-date4-proto.WHAT,
        Config::TOML::Parser::Grammar,
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
        $match-date5.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse(
               $date5,
               :rule<date-time-omit-local-offset>
           )] - 25 of 28
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal datetime (omit local offset)
        ┃   Success   ┃    successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-date5-proto.WHAT,
        Config::TOML::Parser::Grammar,
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
        $match-date6.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($date6, :rule<full-date>)] - 27 of 28
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal datetime (omit local offset
        ┃   Success   ┃    and time) successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-date6-proto.WHAT,
        Config::TOML::Parser::Grammar,
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

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
