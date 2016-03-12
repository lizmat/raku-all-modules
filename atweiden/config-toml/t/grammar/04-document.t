use v6;
use lib 'lib';
use Test;
use Config::TOML::Parser::Grammar;

plan 1;

# document grammar tests {{{

# subtest
{
    # my Str $document = slurp 't/data/example-v0.4.0.toml';
    my Str $document-hard = slurp 't/data/hard_example.toml';
    # my Str $document-standard = slurp 't/data/example.toml';

    # my $match-document = Config::TOML::Parser::Grammar.parse(
    #     $document
    # );
    my $match-document-hard = Config::TOML::Parser::Grammar.parse(
        $document-hard
    );
    # my $match-document-standard = Config::TOML::Parser::Grammar.parse(
    #     $document-standard
    # );

    # is(
    #     $match-document.WHAT,
    #     Match,
    #     q:to/EOF/
    #     ♪ [Grammar.parse($document)] - 1 of 3
    #     ┏━━━━━━━━━━━━━┓
    #     ┃             ┃  ∙ Parses TOML v0.4.0 document successfully
    #     ┃   Success   ┃
    #     ┃             ┃
    #     ┗━━━━━━━━━━━━━┛
    #     EOF
    # );
    is(
        $match-document-hard.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($document-hard)] - 2 of 3
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses TOML v0.4.0 document successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    # is(
    #     $match-document-standard.WHAT,
    #     Match,
    #     q:to/EOF/
    #     ♪ [Grammar.parse($document-standard)] - 3 of 3
    #     ┏━━━━━━━━━━━━━┓
    #     ┃             ┃  ∙ Parses TOML v0.4.0 document successfully
    #     ┃   Success   ┃
    #     ┃             ┃
    #     ┗━━━━━━━━━━━━━┛
    #     EOF
    # );
}

# end document grammar tests }}}

# vim: ft=perl6 fdm=marker fdl=0
