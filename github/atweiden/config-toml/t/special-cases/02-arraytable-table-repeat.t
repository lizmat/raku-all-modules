use v6;
use lib 'lib';
use Test;
use Config::TOML::Parser::Actions;
use Config::TOML::Parser::Grammar;

plan(1);

subtest({
    my Str $toml = Q:to/EOF/;
    # OK
    [[Person]]
    name = "LJ"

    [Person.Demographics]
    agegroup = "18..25"
    region = "US"

    [[Person]]
    name = "Sam"

    [Person.Demographics]
    agegroup = "13..18"
    region = "MX"
    EOF

    my Config::TOML::Parser::Actions $actions .= new();
    my $match-toml = Config::TOML::Parser::Grammar.parse($toml, :$actions);

    is(
        $match-toml.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($toml, :$actions)] - 1 of 7
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses unordered TOML tables successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-toml.made<Person>[0]<name>,
        "LJ",
        q:to/EOF/
        ♪ [Is expected value?] - 2 of 7
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml.made<Person>[0]<name> ~~ "LJ"
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml.made<Person>[0]<Demographics><agegroup>,
        "18..25",
        q:to/EOF/
        ♪ [Is expected value?] - 3 of 7
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml.made<Person>[0]<Demographics><agegroup>
        ┃   Success   ┃        ~~ "18..25"
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml.made<Person>[0]<Demographics><region>,
        "US",
        q:to/EOF/
        ♪ [Is expected value?] - 4 of 7
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml.made<Person>[0]<Demographics><region>
        ┃   Success   ┃        ~~ "US"
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml.made<Person>[1]<name>,
        "Sam",
        q:to/EOF/
        ♪ [Is expected value?] - 5 of 7
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml.made<Person>[1]<name> ~~ "Sam"
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml.made<Person>[1]<Demographics><agegroup>,
        "13..18",
        q:to/EOF/
        ♪ [Is expected value?] - 6 of 7
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml.made<Person>[1]<Demographics><agegroup>
        ┃   Success   ┃        ~~ "13..18"
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml.made<Person>[1]<Demographics><region>,
        "MX",
        q:to/EOF/
        ♪ [Is expected value?] - 7 of 7
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml.made<Person>[1]<Demographics><region>
        ┃   Success   ┃        ~~ "MX"
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
});

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
