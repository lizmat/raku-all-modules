use v6;
use lib 'lib';
use Test;
use Config::TOML::Parser::Actions;
use Config::TOML::Parser::Grammar;

plan 17;

subtest
{
    my Str $toml = Q:to/EOF/;
    # DO NOT DO THIS
    [a]
    b = 1
    b = 2
    EOF

    my Config::TOML::Parser::Actions $actions .= new;
    throws-like(
        {Config::TOML::Parser::Grammar.parse($toml, :$actions)},
        X::Config::TOML::HOH::DuplicateKeys,
        q:to/EOF/
        ♪ [Grammar.parse($toml, :$actions)] - 1 of 17
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Throws exception
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

subtest
{
    my Str $toml = Q:to/EOF/;
    # DO NOT DO THIS
    a = { b = 1, b = 2, c = 3 }
    EOF

    my Config::TOML::Parser::Actions $actions .= new;
    throws-like(
        {Config::TOML::Parser::Grammar.parse($toml, :$actions)},
        X::Config::TOML::InlineTable::DuplicateKeys,
        q:to/EOF/
        ♪ [Grammar.parse($toml, :$actions)] - 2 of 17
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Throws exception
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

subtest
{
    my Str $toml = Q:to/EOF/;
    # DO NOT DO THIS
    a = 2
    a = 3
    EOF

    my Config::TOML::Parser::Actions $actions .= new;
    throws-like(
        {Config::TOML::Parser::Grammar.parse($toml, :$actions)},
        X::Config::TOML::KeypairLine::DuplicateKeys,
        q:to/EOF/
        ♪ [Grammar.parse($toml, :$actions)] - 3 of 17
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Throws exception
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

subtest
{
    my Str $toml = Q:to/EOF/;
    # DO NOT DO THIS
    [a]
    b = 1

    [a]
    c = 2
    EOF

    my Config::TOML::Parser::Actions $actions .= new;
    throws-like(
        {Config::TOML::Parser::Grammar.parse($toml, :$actions)},
        X::Config::TOML::HOH::Seen,
        q:to/EOF/
        ♪ [Grammar.parse($toml, :$actions)] - 4 of 17
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Throws exception
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

subtest
{
    my Str $toml = Q:to/EOF/;
    # DO NOT DO THIS
    [a]
    [a]
    EOF

    my Config::TOML::Parser::Actions $actions .= new;
    throws-like(
        {Config::TOML::Parser::Grammar.parse($toml, :$actions)},
        X::Config::TOML::HOH::Seen,
        q:to/EOF/
        ♪ [Grammar.parse($toml, :$actions)] - 5 of 17
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Throws exception
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

subtest
{
    my Str $toml = Q:to/EOF/;
    # DO NOT DO THIS
    [a.b]
    c = 1

    [[a]]
    b = 2
    EOF

    my Config::TOML::Parser::Actions $actions .= new;
    throws-like(
        {Config::TOML::Parser::Grammar.parse($toml, :$actions)},
        X::Config::TOML::Keypath::AOH,
        q:to/EOF/
        ♪ [Grammar.parse($toml, :$actions)] - 6 of 17
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Throws exception
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

subtest
{
    my Str $toml = Q:to/EOF/;
    # DO NOT DO THIS
    [a]
    [[a]]
    EOF

    my Config::TOML::Parser::Actions $actions .= new;
    throws-like(
        {Config::TOML::Parser::Grammar.parse($toml, :$actions)},
        X::Config::TOML::AOH::OverwritesHOH,
        q:to/EOF/
        ♪ [Grammar.parse($toml, :$actions)] - 7 of 17
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Throws exception
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

subtest
{
    my Str $toml = Q:to/EOF/;
    # DO NOT DO THIS
    [[a]]
    b = 1

    [a]
    c = 2
    EOF

    my Config::TOML::Parser::Actions $actions .= new;
    throws-like(
        {Config::TOML::Parser::Grammar.parse($toml, :$actions)},
        X::Config::TOML::HOH::Seen::AOH,
        q:to/EOF/
        ♪ [Grammar.parse($toml, :$actions)] - 8 of 17
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Throws exception
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

subtest
{
    my Str $toml = Q:to/EOF/;
    # DO NOT DO THIS
    [[a]]
    [a]
    EOF

    my Config::TOML::Parser::Actions $actions .= new;
    throws-like(
        {Config::TOML::Parser::Grammar.parse($toml, :$actions)},
        X::Config::TOML::HOH::Seen::AOH,
        q:to/EOF/
        ♪ [Grammar.parse($toml, :$actions)] - 9 of 17
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Throws exception
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

subtest
{
    my Str $toml = Q:to/EOF/;
    # DO NOT DO THIS
    [fruit]
    type = "apple"

    [fruit.type]
    apple = "yes"
    EOF

    my Config::TOML::Parser::Actions $actions .= new;
    throws-like(
        {Config::TOML::Parser::Grammar.parse($toml, :$actions)},
        X::Config::TOML::HOH::Seen::Key,
        q:to/EOF/
        ♪ [Grammar.parse($toml, :$actions)] - 10 of 17
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Throws exception
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

subtest
{
    my Str $toml = Q:to/EOF/;
    # DO NOT DO THIS
    a = 1

    [a]
    c = 2
    EOF

    my Config::TOML::Parser::Actions $actions .= new;
    throws-like(
        {Config::TOML::Parser::Grammar.parse($toml, :$actions)},
        X::Config::TOML::HOH::Seen::Key,
        q:to/EOF/
        ♪ [Grammar.parse($toml, :$actions)] - 11 of 17
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Throws exception
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

subtest
{
    my Str $toml = Q:to/EOF/;
    # DO NOT DO THIS
    a = 1

    [a.b]
    c = 2
    EOF

    my Config::TOML::Parser::Actions $actions .= new;
    throws-like(
        {Config::TOML::Parser::Grammar.parse($toml, :$actions)},
        X::Config::TOML::Keypath::HOH,
        q:to/EOF/
        ♪ [Grammar.parse($toml, :$actions)] - 12 of 17
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Throws exception
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

subtest
{
    # TODO: change this to throw X::Config::TOML::HOH::Seen::Key
    my Str $toml = Q:to/EOF/;
    # DO NOT DO THIS
    a = { b = 1 }

    [a.b]
    c = 2
    EOF

    my Config::TOML::Parser::Actions $actions .= new;
    throws-like(
        {Config::TOML::Parser::Grammar.parse($toml, :$actions)},
        X::Config::TOML::Keypath::HOH,
        q:to/EOF/
        ♪ [Grammar.parse($toml, :$actions)] - 13 of 17
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Throws exception
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

subtest
{
    my Str $toml = Q:to/EOF/;
    # DO NOT DO THIS
    a = [ { a = 1, b = 2, c = 3 }, { d = 4, e = 5, f = 6 } ]

    [[a]]
    g = 7
    h = 8
    i = 9
    EOF

    my Config::TOML::Parser::Actions $actions .= new;
    throws-like(
        {Config::TOML::Parser::Grammar.parse($toml, :$actions)},
        X::Config::TOML::AOH::OverwritesKey,
        q:to/EOF/
        ♪ [Grammar.parse($toml, :$actions)] - 14 of 17
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Throws exception
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

subtest
{
    my Str $toml = Q:to/EOF/;
    # DO NOT DO THIS
    [header1]
    header1key1 = { inlinetablekey1 = 1, inlinetablekey2 = 2 }

    [header1.header1key1]
    number = 9
    EOF

    my Config::TOML::Parser::Actions $actions .= new;
    throws-like(
        {Config::TOML::Parser::Grammar.parse($toml, :$actions)},
        X::Config::TOML::HOH::Seen::Key,
        q:to/EOF/
        ♪ [Grammar.parse($toml, :$actions)] - 15 of 17
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Throws exception
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

subtest
{
    my Str $toml = Q:to/EOF/;
    # DO NOT DO THIS
    a = { b = 1 }

    [a]
    c = 2
    EOF

    my Config::TOML::Parser::Actions $actions .= new;
    throws-like(
        {Config::TOML::Parser::Grammar.parse($toml, :$actions)},
        X::Config::TOML::HOH::Seen::Key,
        q:to/EOF/
        ♪ [Grammar.parse($toml, :$actions)] - 16 of 17
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Throws exception
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

subtest
{
    my Str $toml = Q:to/EOF/;
    # DO NOT DO THIS
    places = [
        { a = [ ["AR", "Armenia"], ["AS", "Astoria"] ] },
        { b = [ ["BO", "Bolivia"], ["BR", "Brasilia"] ] },
        { c = [ ["CA", "California"], ["CA", "Catalonia"] ] }
    ]

    [[places.constellations]]
    a = [ ["AN", "Andromeda"], ["AQ", "Aquarius"] ]
    EOF

    my Config::TOML::Parser::Actions $actions .= new;
    throws-like(
        {Config::TOML::Parser::Grammar.parse($toml, :$actions)},
        X::Config::TOML::AOH::OverwritesKey,
        q:to/EOF/
        ♪ [Grammar.parse($toml, :$actions)] - 17 of 17
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Throws exception
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

# vim: ft=perl6
