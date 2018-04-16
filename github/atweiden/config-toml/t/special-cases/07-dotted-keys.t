use v6;
use lib 'lib';
use Test;
use Config::TOML::Parser::Actions;
use Config::TOML::Parser::Grammar;

plan(2);

subtest({
    my Str $toml-a = Q:to/EOF/;
    a.b.c.d = 123
    EOF

    my Str $toml-b = Q:to/EOF/;
    [a.b.c]
    d = 123
    EOF

    my Str $toml-c = Q:to/EOF/;
    [a.b]
    c.d = 123
    EOF

    my Str $toml-d = Q:to/EOF/;
    [a]
    b.c.d = 123
    EOF

    my Str $toml-e = Q:to/EOF/;
    a = { b = { c = { d = 123 } } }
    EOF

    my Config::TOML::Parser::Actions $actions-a .= new;
    my Config::TOML::Parser::Actions $actions-b .= new;
    my Config::TOML::Parser::Actions $actions-c .= new;
    my Config::TOML::Parser::Actions $actions-d .= new;
    my Config::TOML::Parser::Actions $actions-e .= new;
    my $match-toml-a =
        Config::TOML::Parser::Grammar.parse($toml-a, :actions($actions-a));
    my $match-toml-b =
        Config::TOML::Parser::Grammar.parse($toml-b, :actions($actions-b));
    my $match-toml-c =
        Config::TOML::Parser::Grammar.parse($toml-c, :actions($actions-c));
    my $match-toml-d =
        Config::TOML::Parser::Grammar.parse($toml-d, :actions($actions-d));
    my $match-toml-e =
        Config::TOML::Parser::Grammar.parse($toml-e, :actions($actions-e));

    is(
        $match-toml-a.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($toml-a, :$actions)] - 1 of 24
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses TOML with dotted keys successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml-b.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($toml-b, :$actions)] - 2 of 24
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses TOML with dotted keys successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml-c.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($toml-c, :$actions)] - 3 of 24
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses TOML with dotted keys successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml-d.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($toml-d, :$actions)] - 4 of 24
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses TOML with dotted keys successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml-e.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($toml-e, :$actions)] - 5 of 24
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses TOML with dotted keys successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml-a.made<a><b><c><d>,
        123,
        q:to/EOF/
        ♪ [Is expected value?] - 6 of 24
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml-a.made<a><b><c><d> == 123
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml-b.made<a><b><c><d>,
        123,
        q:to/EOF/
        ♪ [Is expected value?] - 7 of 24
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml-b.made<a><b><c><d> == 123
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml-c.made<a><b><c><d>,
        123,
        q:to/EOF/
        ♪ [Is expected value?] - 8 of 24
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml-c.made<a><b><c><d> == 123
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml-d.made<a><b><c><d>,
        123,
        q:to/EOF/
        ♪ [Is expected value?] - 9 of 24
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml-d.made<a><b><c><d> == 123
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml-e.made<a><b><c><d>,
        123,
        q:to/EOF/
        ♪ [Is expected value?] - 10 of 24
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml-e.made<a><b><c><d> == 123
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
});

subtest({
    my Str $toml-a = Q:to/EOF/;
    [[a]]
    b.c.d = 123
    EOF

    my Str $toml-b = Q:to/EOF/;
    [[a]]
      [a.b.c]
      d = 123
    EOF

    my Str $toml-c = Q:to/EOF/;
    [[a]]
      [a.b]
      c.d = 123
    EOF

    my Str $toml-d = Q:to/EOF/;
    a = [
      { b = { c = { d = 123 } } }
    ]
    EOF

    my Str $toml-e = Q:to/EOF/;
    a = [
      { b.c.d = 123 }
    ]
    EOF

    my Str $toml-f = Q:to/EOF/;
    a = [
      { b.c = { d = 123 } }
    ]
    EOF

    my Str $toml-g = Q:to/EOF/;
    a = [
      { b = { c.d = 123 } }
    ]
    EOF

    my Config::TOML::Parser::Actions $actions-a .= new;
    my Config::TOML::Parser::Actions $actions-b .= new;
    my Config::TOML::Parser::Actions $actions-c .= new;
    my Config::TOML::Parser::Actions $actions-d .= new;
    my Config::TOML::Parser::Actions $actions-e .= new;
    my Config::TOML::Parser::Actions $actions-f .= new;
    my Config::TOML::Parser::Actions $actions-g .= new;
    my $match-toml-a =
        Config::TOML::Parser::Grammar.parse($toml-a, :actions($actions-a));
    my $match-toml-b =
        Config::TOML::Parser::Grammar.parse($toml-b, :actions($actions-b));
    my $match-toml-c =
        Config::TOML::Parser::Grammar.parse($toml-c, :actions($actions-c));
    my $match-toml-d =
        Config::TOML::Parser::Grammar.parse($toml-d, :actions($actions-d));
    my $match-toml-e =
        Config::TOML::Parser::Grammar.parse($toml-e, :actions($actions-e));
    my $match-toml-f =
        Config::TOML::Parser::Grammar.parse($toml-f, :actions($actions-f));
    my $match-toml-g =
        Config::TOML::Parser::Grammar.parse($toml-g, :actions($actions-g));

    is(
        $match-toml-a.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($toml-a, :$actions)] - 11 of 24
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses TOML with dotted keys successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml-b.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($toml-b, :$actions)] - 12 of 24
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses TOML with dotted keys successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml-c.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($toml-c, :$actions)] - 13 of 24
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses TOML with dotted keys successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml-d.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($toml-d, :$actions)] - 14 of 24
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses TOML with dotted keys successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml-e.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($toml-e, :$actions)] - 15 of 24
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses TOML with dotted keys successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml-f.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($toml-f, :$actions)] - 16 of 24
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses TOML with dotted keys successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml-g.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($toml-g, :$actions)] - 17 of 24
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses TOML with dotted keys successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml-a.made<a>[0]<b><c><d>,
        123,
        q:to/EOF/
        ♪ [Is expected value?] - 18 of 24
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml-a.made<a>[0]<b><c><d> == 123
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml-b.made<a>[0]<b><c><d>,
        123,
        q:to/EOF/
        ♪ [Is expected value?] - 19 of 24
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml-b.made<a>[0]<b><c><d> == 123
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml-c.made<a>[0]<b><c><d>,
        123,
        q:to/EOF/
        ♪ [Is expected value?] - 20 of 24
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml-c.made<a>[0]<b><c><d> == 123
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml-d.made<a>[0]<b><c><d>,
        123,
        q:to/EOF/
        ♪ [Is expected value?] - 21 of 24
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml-d.made<a>[0]<b><c><d> == 123
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml-e.made<a>[0]<b><c><d>,
        123,
        q:to/EOF/
        ♪ [Is expected value?] - 22 of 24
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml-e.made<a>[0]<b><c><d> == 123
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml-f.made<a>[0]<b><c><d>,
        123,
        q:to/EOF/
        ♪ [Is expected value?] - 23 of 24
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml-f.made<a>[0]<b><c><d> == 123
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml-g.made<a>[0]<b><c><d>,
        123,
        q:to/EOF/
        ♪ [Is expected value?] - 24 of 24
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml-g.made<a>[0]<b><c><d> == 123
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
});

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
