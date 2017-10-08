use v6;
use lib 'lib';
use Test;
use Config::TOML::Parser::Actions;
use Config::TOML::Parser::Grammar;

plan 1;

subtest
{
    # https://github.com/toml-lang/toml/commit/27dc0ad209931ebb336be7769501ff091cffd355
    # Clarify that literal strings can be table keys
    my Str $toml = Q:to/EOF/;
    [ j . "ʞ" . 'l' ]
    'key2' = "value"
    'quoted "value"' = "value"
    EOF

    my Config::TOML::Parser::Actions $actions .= new;
    my $match-toml = Config::TOML::Parser::Grammar.parse($toml, :$actions);

    is(
        $match-toml.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($toml, :$actions)] - 1 of 3
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses unordered TOML tables successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml.made<j><ʞ><l><key2>,
        'value',
        q:to/EOF/
        ♪ [Is expected value?] - 2 of 3
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml.made<j><ʞ><l><key2> eq 'value'
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml.made<j><ʞ><l>{'quoted "value"'},
        'value',
        q:to/EOF/
        ♪ [Is expected value?] - 3 of 3
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml.made<j><ʞ><l>{'quoted "value"'} eq 'value'
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
