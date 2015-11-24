use v6;
use lib 'lib';
use Test;
use Config::TOML::Parser::Grammar;

plan 3;

# document grammar tests {{{

# subtest
{
    my Str $document = slurp 't/data/example-v0.4.0.toml';
    my Str $document_hard = slurp 't/data/hard_example.toml';
    my Str $document_standard = slurp 't/data/example.toml';

    my $match_document = Config::TOML::Parser::Grammar.parse(
        $document
    );
    my $match_document_hard = Config::TOML::Parser::Grammar.parse(
        $document_hard
    );
    my $match_document_standard = Config::TOML::Parser::Grammar.parse(
        $document_standard
    );

    is(
        $match_document.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($document)] - 1 of 3
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses TOML v0.4.0 document successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_document_hard.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($document_hard)] - 2 of 3
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses TOML v0.4.0 document successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match_document_standard.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($document_standard)] - 3 of 3
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses TOML v0.4.0 document successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

# end table grammar tests }}}

# vim: ft=perl6 fdm=marker fdl=0
