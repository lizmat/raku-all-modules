use v6;
use lib 'lib';
use Test;
use Config::TOML::Parser::Actions;
use Config::TOML::Parser::Grammar;

plan 1;

subtest
{
    # https://github.com/toml-lang/toml/issues/331#issuecomment-111769128
    # This config is possible. The order is not important as long as no
    # key-value pair is redefined:
    my Str $toml = Q:to/EOF/;
    [table.sub1]
    item = "ok"
    [table]
    item = "ok"
    [table.sub2]
    item = "ok"
    EOF

    my Config::TOML::Parser::Actions $actions .= new;
    my $match_toml = Config::TOML::Parser::Grammar.parse($toml, :$actions);

    is(
        $match_toml.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($toml, :$actions)] - 1 of 4
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses unordered TOML tables successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match_toml.made<table><sub1><item>,
        "ok",
        q:to/EOF/
        ♪ [Is expected value?] - 2 of 4
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_toml.made<table><sub1><item> ~~ "ok"
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_toml.made<table><item>,
        "ok",
        q:to/EOF/
        ♪ [Is expected value?] - 3 of 4
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_toml.made<table><item> ~~ "ok"
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_toml.made<table><sub2><item>,
        "ok",
        q:to/EOF/
        ♪ [Is expected value?] - 4 of 4
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match_toml.made<table><sub2><item> ~~ "ok"
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

# vim: ft=perl6
