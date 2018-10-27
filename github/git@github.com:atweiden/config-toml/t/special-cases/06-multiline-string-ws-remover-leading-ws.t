use v6;
use lib 'lib';
use Test;
use Config::TOML::Parser::Actions;
use Config::TOML::Parser::Grammar;

plan(1);

subtest({
    my Str $toml = Q:to/EOF/;
    # contains trailing horizontal whitespace after backslash
    ws = """
    first line \  
        and first line continued
    """
    EOF

    my Config::TOML::Parser::Actions $actions .= new;
    my $match-toml = Config::TOML::Parser::Grammar.parse($toml, :$actions);

    is(
        $match-toml.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($toml, :$actions)] - 1 of 2
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses multiline string successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml.made<ws>,
        "first line and first line continued\n",
        q:to/EOF/
        ♪ [Is expected value?] - 2 of 2
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml.made<ws> eq "first line and first line continued\n"
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
});

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
