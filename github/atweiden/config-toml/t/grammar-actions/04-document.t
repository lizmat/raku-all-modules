use v6;
use lib 'lib';
use Test;
use Config::TOML::Parser::Actions;
use Config::TOML::Parser::Grammar;

plan(1);

# document grammar tests {{{

subtest({
    my Str $document = slurp('t/data/example-v0.4.0.toml');
    my Str $document-hard = slurp('t/data/hard_example.toml');
    my Str $document-standard = slurp('t/data/example.toml');

    my Config::TOML::Parser::Actions $actions .= new;
    my $match-document =
        Config::TOML::Parser::Grammar.parse(
            $document,
            :$actions
        );

    my Config::TOML::Parser::Actions $actions-hard .= new;
    my $match-document-hard =
        Config::TOML::Parser::Grammar.parse(
            $document-hard,
            :actions($actions-hard)
        );

    my Config::TOML::Parser::Actions $actions-standard .= new;
    my $match-document-standard =
        Config::TOML::Parser::Grammar.parse(
            $document-standard,
            :actions($actions-standard)
        );

    is(
        $match-document.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($document)] - 1 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses TOML v0.4.0 document successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document-hard.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($document-hard)] - 2 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses TOML v0.4.0 document successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document-standard.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($document-standard)] - 3 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses TOML v0.4.0 document successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-document.made.WHAT,
        Hash,
        q:to/EOF/
        ♪ [Is hash?] - 4 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made.WHAT ~~ Hash
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document-hard.made.WHAT,
        Hash,
        q:to/EOF/
        ♪ [Is hash?] - 5 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document-hard.made.WHAT ~~ Hash
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document-standard.made.WHAT,
        Hash,
        q:to/EOF/
        ♪ [Is hash?] - 6 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document-standard.made.WHAT ~~ Hash
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-document.made<table><key>,
        "value",
        q:to/EOF/
        ♪ [Is expected value?] - 7 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<table><key>
        ┃   Success   ┃        ~~ "value"
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<table><subtable><key>,
        "another value",
        q:to/EOF/
        ♪ [Is expected value?] - 8 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<table><subtable><key>
        ┃   Success   ┃        ~~ "another value"
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<x><y><z><w>,
        {},
        q:to/EOF/
        ♪ [Is expected value?] - 9 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<x><y><z><w>
        ┃   Success   ┃        ~~ {}
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<table><inline><name>,
        %( first => "Tom", last => "Preston-Werner" ),
        q:to/EOF/
        ♪ [Is expected value?] - 10 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<table><inline><name>
        ┃   Success   ┃        ~~ %( first => "Tom", last => "Preston-Werner" )
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<table><inline><name><first>,
        "Tom",
        q:to/EOF/
        ♪ [Is expected value?] - 11 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<table><inline><name><first>
        ┃   Success   ┃        ~~ 'Tom'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<table><inline><name><last>,
        "Preston-Werner",
        q:to/EOF/
        ♪ [Is expected value?] - 12 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<table><inline><name><last>
        ┃   Success   ┃        ~~ 'Preston-Werner'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<table><inline><point>,
        %( x => 1, y => 2 ),
        q:to/EOF/
        ♪ [Is expected value?] - 13 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<table><inline><point>
        ┃   Success   ┃        ~~ %( x => 1, y => 2 )
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<table><inline><point><x>,
        1,
        q:to/EOF/
        ♪ [Is expected value?] - 14 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<table><inline><point><x>
        ┃   Success   ┃        == 1
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<table><inline><point><y>,
        2,
        q:to/EOF/
        ♪ [Is expected value?] - 15 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<table><inline><point><y>
        ┃   Success   ┃        == 2
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<string><basic><basic>,
        "I'm a string. \"You can quote me\". Name\tJosé\nLocation\tSF.",
        q:to/EOF/
        ♪ [Is expected value?] - 16 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<string><basic><basic>
        ┃   Success   ┃        ~~ "..."
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<string><multiline><key1>,
        "One\nTwo",
        q:to/EOF/
        ♪ [Is expected value?] - 17 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<string><multiline><key1>
        ┃   Success   ┃        ~~ "One\nTwo"
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<string><multiline><key2>,
        "One\nTwo",
        q:to/EOF/
        ♪ [Is expected value?] - 18 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<string><multiline><key2>
        ┃   Success   ┃        ~~ "One\nTwo"
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<string><multiline><key3>,
        "One\nTwo",
        q:to/EOF/
        ♪ [Is expected value?] - 19 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<string><multiline><key3>
        ┃   Success   ┃        ~~ "One\nTwo"
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<string><multiline><continued><key1>,
        "The quick brown fox jumps over the lazy dog.",
        q:to/EOF/
        ♪ [Is expected value?] - 20 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<string><multiline><continued><key1>
        ┃   Success   ┃        ~~ "The quick brown fox jumps over the lazy dog."
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<string><multiline><continued><key2>,
        "The quick brown fox jumps over the lazy dog.",
        q:to/EOF/
        ♪ [Is expected value?] - 21 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<string><multiline><continued><key2>
        ┃   Success   ┃        ~~ "The quick brown fox jumps over the lazy dog."
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<string><multiline><continued><key3>,
        "The quick brown fox jumps over the lazy dog.",
        q:to/EOF/
        ♪ [Is expected value?] - 22 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<string><multiline><continued><key3>
        ┃   Success   ┃        ~~ "The quick brown fox jumps over the lazy dog."
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<string><literal><winpath>,
        'C:\Users\nodejs\templates',
        q:to/EOF/
        ♪ [Is expected value?] - 23 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<string><literal><winpath>
        ┃   Success   ┃        ~~ 'C:\Users\nodejs\templates'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    my Str $winpath2 = Q:to/EOF/;
    \\ServerX\admin$\system32\
    EOF
    is(
        $match-document.made<string><literal><winpath2>,
        $winpath2.trim,
        q:to/EOF/
        ♪ [Is expected value?] - 24 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<string><literal><winpath2>
        ┃   Success   ┃        ~~ '...'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<string><literal><quoted>,
        'Tom "Dubs" Preston-Werner',
        q:to/EOF/
        ♪ [Is expected value?] - 25 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<string><literal><quoted>
        ┃   Success   ┃        ~~ 'Tom "Dubs" Preston-Werner'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<string><literal><regex>,
        '<\i\c*\s*>',
        q:to/EOF/
        ♪ [Is expected value?] - 26 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<string><literal><regex>
        ┃   Success   ┃        ~~ '<\i\c*\s*>'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    my Str $regex2 = Q{I [dw]on't need \d{2} apples};
    is(
        $match-document.made<string><literal><multiline><regex2>,
        $regex2,
        q:to/EOF/
        ♪ [Is expected value?] - 27 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<string><literal><multiline><regex2>
        ┃   Success   ┃        ~~ '...'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<string><literal><multiline><lines>,
        "The first newline is\ntrimmed in raw strings.\n   All other whitespace\n   is preserved.\n",
        q:to/EOF/
        ♪ [Is expected value?] - 28 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<string><literal><multiline><lines>
        ┃   Success   ┃        ~~ '...'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<integer><key1>,
        99,
        q:to/EOF/
        ♪ [Is expected value?] - 29 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<integer><key1>
        ┃   Success   ┃        == 99
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<integer><key2>,
        42,
        q:to/EOF/
        ♪ [Is expected value?] - 30 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<integer><key2>
        ┃   Success   ┃        == 42
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<integer><key3>,
        0,
        q:to/EOF/
        ♪ [Is expected value?] - 31 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<integer><key3>
        ┃   Success   ┃        == 0
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<integer><key4>,
        -17,
        q:to/EOF/
        ♪ [Is expected value?] - 32 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<integer><key4>
        ┃   Success   ┃        == -17
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<integer><underscores><key1>,
        1000,
        q:to/EOF/
        ♪ [Is expected value?] - 33 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<integer><underscores><key1>
        ┃   Success   ┃        == 1000
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<integer><underscores><key2>,
        5349221,
        q:to/EOF/
        ♪ [Is expected value?] - 34 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<integer><underscores><key2>
        ┃   Success   ┃        == 5349221
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<integer><underscores><key3>,
        12345,
        q:to/EOF/
        ♪ [Is expected value?] - 35 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<integer><underscores><key3>
        ┃   Success   ┃        == 12345
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<float><fractional><key1>,
        1.0,
        q:to/EOF/
        ♪ [Is expected value?] - 36 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<float><fractional><key1>
        ┃   Success   ┃        == 1.0
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<float><fractional><key2>,
        3.1415,
        q:to/EOF/
        ♪ [Is expected value?] - 37 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<float><fractional><key2>
        ┃   Success   ┃        == 3.1415
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<float><fractional><key3>,
        -0.01,
        q:to/EOF/
        ♪ [Is expected value?] - 38 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<float><fractional><key3>
        ┃   Success   ┃        == -0.01
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<float><exponent><key1>,
        5e22,
        q:to/EOF/
        ♪ [Is expected value?] - 39 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<float><exponent><key1>
        ┃   Success   ┃        == 5e22
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<float><exponent><key2>,
        1e6,
        q:to/EOF/
        ♪ [Is expected value?] - 40 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<float><exponent><key2>
        ┃   Success   ┃        == 1e6
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<float><exponent><key3>,
        -2e-2,
        q:to/EOF/
        ♪ [Is expected value?] - 41 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<float><exponent><key3>
        ┃   Success   ┃        == -2e-2
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<float><both><key>,
        6.626e-34,
        q:to/EOF/
        ♪ [Is expected value?] - 42 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<float><both><key>
        ┃   Success   ┃        == 6.626e-34
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<float><underscores><key1>,
        9224617.445991228313,
        q:to/EOF/
        ♪ [Is expected value?] - 43 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<float><underscores><key1>
        ┃   Success   ┃        == 9224617.445991228313
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<float><underscores><key2>,
        1e1000,
        q:to/EOF/
        ♪ [Is expected value?] - 44 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<float><underscores><key2>
        ┃   Success   ┃        == 1e1000
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<boolean><True>,
        True,
        q:to/EOF/
        ♪ [Is expected value?] - 45 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<boolean><True>
        ┃   Success   ┃        ~~ True
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<boolean><False>,
        False,
        q:to/EOF/
        ♪ [Is expected value?] - 46 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<boolean><False>
        ┃   Success   ┃        ~~ False
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<datetime><key1>,
        '1979-05-27T07:32:00Z',
        q:to/EOF/
        ♪ [Is expected value?] - 47 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<datetime><key1>
        ┃   Success   ┃        ~~ '1979-05-27T07:32:00Z'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<datetime><key2>,
        '1979-05-27T00:32:00-07:00',
        q:to/EOF/
        ♪ [Is expected value?] - 48 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<datetime><key2>
        ┃   Success   ┃        ~~ '1979-05-27T00:32:00-07:00'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<datetime><key3>,
        '1979-05-27T00:32:00.999999-07:00',
        q:to/EOF/
        ♪ [Is expected value?] - 49 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<datetime><key3>
        ┃   Success   ┃        ~~ '1979-05-27T00:32:00.999999-07:00'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<array><key1>,
        [ 1, 2, 3 ],
        q:to/EOF/
        ♪ [Is expected value?] - 50 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<array><key1>
        ┃   Success   ┃        ~~ [ 1, 2, 3 ]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<array><key1>[0],
        1,
        q:to/EOF/
        ♪ [Is expected value?] - 51 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<array><key1>[0]
        ┃   Success   ┃        == 1
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<array><key1>[1],
        2,
        q:to/EOF/
        ♪ [Is expected value?] - 52 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<array><key1>[1]
        ┃   Success   ┃        == 2
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<array><key1>[2],
        3,
        q:to/EOF/
        ♪ [Is expected value?] - 53 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<array><key1>[2]
        ┃   Success   ┃        == 3
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<array><key2>,
        [ "red", "yellow", "green" ],
        q:to/EOF/
        ♪ [Is expected value?] - 54 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<array><key2>
        ┃   Success   ┃        ~~ [ "red", "yellow", "green" ]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<array><key2>[0],
        "red",
        q:to/EOF/
        ♪ [Is expected value?] - 55 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<array><key2>[0]
        ┃   Success   ┃        ~~ "red"
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<array><key2>[1],
        "yellow",
        q:to/EOF/
        ♪ [Is expected value?] - 56 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<array><key2>[1]
        ┃   Success   ┃        ~~ "yellow"
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<array><key2>[2],
        "green",
        q:to/EOF/
        ♪ [Is expected value?] - 57 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<array><key2>[2]
        ┃   Success   ┃        ~~ "green"
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<array><key3>,
        [ [ 1, 2 ], [3, 4, 5] ],
        q:to/EOF/
        ♪ [Is expected value?] - 58 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<array><key3>
        ┃   Success   ┃        ~~ [ [ 1, 2 ], [3, 4, 5] ]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<array><key3>[0],
        [ 1, 2 ],
        q:to/EOF/
        ♪ [Is expected value?] - 59 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<array><key3>[0]
        ┃   Success   ┃        ~~ [ 1, 2 ]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<array><key3>[0][0],
        1,
        q:to/EOF/
        ♪ [Is expected value?] - 60 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<array><key3>[0][0]
        ┃   Success   ┃        == 1
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<array><key3>[0][1],
        2,
        q:to/EOF/
        ♪ [Is expected value?] - 61 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<array><key3>[0][1]
        ┃   Success   ┃        == 2
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<array><key3>[1],
        [ 3, 4, 5 ],
        q:to/EOF/
        ♪ [Is expected value?] - 62 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<array><key3>[1]
        ┃   Success   ┃        ~~ [ 3, 4, 5 ]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<array><key3>[1][0],
        3,
        q:to/EOF/
        ♪ [Is expected value?] - 63 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<array><key3>[1][0]
        ┃   Success   ┃        == 3
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<array><key3>[1][1],
        4,
        q:to/EOF/
        ♪ [Is expected value?] - 64 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<array><key3>[1][1]
        ┃   Success   ┃        == 4
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<array><key3>[1][2],
        5,
        q:to/EOF/
        ♪ [Is expected value?] - 65 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<array><key3>[1][2]
        ┃   Success   ┃        == 5
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<array><key4>,
        [ [ 1, 2 ], ["a", "b", "c"] ],
        q:to/EOF/
        ♪ [Is expected value?] - 66 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<array><key4>
        ┃   Success   ┃        ~~ [ [ 1, 2 ], ["a", "b", "c"] ]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<array><key4>[0],
        [ 1, 2 ],
        q:to/EOF/
        ♪ [Is expected value?] - 67 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<array><key4>[0]
        ┃   Success   ┃        ~~ [ 1, 2 ]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<array><key4>[0][0],
        1,
        q:to/EOF/
        ♪ [Is expected value?] - 68 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<array><key4>[0][0]
        ┃   Success   ┃        == 1
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<array><key4>[0][1],
        2,
        q:to/EOF/
        ♪ [Is expected value?] - 69 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<array><key4>[0][1]
        ┃   Success   ┃        == 2
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<array><key4>[1],
        [ "a", "b", "c" ],
        q:to/EOF/
        ♪ [Is expected value?] - 70 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<array><key4>[1]
        ┃   Success   ┃        ~~ [ "a", "b", "c" ]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<array><key4>[1][0],
        "a",
        q:to/EOF/
        ♪ [Is expected value?] - 71 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<array><key4>[1][0]
        ┃   Success   ┃        ~~ "a"
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<array><key4>[1][1],
        "b",
        q:to/EOF/
        ♪ [Is expected value?] - 72 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<array><key4>[1][1]
        ┃   Success   ┃        ~~ "b"
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<array><key4>[1][2],
        "c",
        q:to/EOF/
        ♪ [Is expected value?] - 73 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<array><key4>[1][2]
        ┃   Success   ┃        ~~ "c"
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<array><key5>,
        [ 1, 2, 3 ],
        q:to/EOF/
        ♪ [Is expected value?] - 74 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<array><key5>
        ┃   Success   ┃        ~~ [ 1, 2, 3 ]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<array><key5>[0],
        1,
        q:to/EOF/
        ♪ [Is expected value?] - 75 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<array><key5>[0]
        ┃   Success   ┃        == 1
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<array><key5>[1],
        2,
        q:to/EOF/
        ♪ [Is expected value?] - 76 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<array><key5>[1]
        ┃   Success   ┃        == 2
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<array><key5>[2],
        3,
        q:to/EOF/
        ♪ [Is expected value?] - 77 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<array><key5>[2]
        ┃   Success   ┃        == 3
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<array><key6>,
        [ 1, 2 ],
        q:to/EOF/
        ♪ [Is expected value?] - 78 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<array><key6>
        ┃   Success   ┃        ~~ [ 1, 2 ]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<array><key6>[0],
        1,
        q:to/EOF/
        ♪ [Is expected value?] - 79 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<array><key6>[0]
        ┃   Success   ┃        == 1
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<array><key6>[1],
        2,
        q:to/EOF/
        ♪ [Is expected value?] - 80 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<array><key6>[1]
        ┃   Success   ┃        == 2
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<products>[0]<name>,
        "Hammer",
        q:to/EOF/
        ♪ [Is expected value?] - 81 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<products>[0]<name>
        ┃   Success   ┃        ~~ "Hammer"
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<products>[0]<sku>,
        738594937,
        q:to/EOF/
        ♪ [Is expected value?] - 82 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<products>[0]<sku>
        ┃   Success   ┃        == 738594937
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<products>[1],
        {},
        q:to/EOF/
        ♪ [Is expected value?] - 83 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<products>[1]
        ┃   Success   ┃        ~~ {}
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<products>[2]<name>,
        "Nail",
        q:to/EOF/
        ♪ [Is expected value?] - 84 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<products>[2]<name>
        ┃   Success   ┃        ~~ "Nail"
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<products>[2]<sku>,
        284758393,
        q:to/EOF/
        ♪ [Is expected value?] - 85 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<products>[2]<sku>
        ┃   Success   ┃        == 284758393
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<products>[2]<color>,
        "gray",
        q:to/EOF/
        ♪ [Is expected value?] - 86 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<products>[2]<color>
        ┃   Success   ┃        ~~ "gray"
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<fruit>[0]<name>,
        "apple",
        q:to/EOF/
        ♪ [Is expected value?] - 87 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<fruit>[0]<name>
        ┃   Success   ┃        ~~ "apple"
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<fruit>[0]<physical><color>,
        "red",
        q:to/EOF/
        ♪ [Is expected value?] - 88 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<fruit>[0]<physical><color>
        ┃   Success   ┃        ~~ "red"
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<fruit>[0]<physical><shape>,
        "round",
        q:to/EOF/
        ♪ [Is expected value?] - 89 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<fruit>[0]<physical><shape>
        ┃   Success   ┃        ~~ "round"
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<fruit>[0]<variety>[0]<name>,
        "red delicious",
        q:to/EOF/
        ♪ [Is expected value?] - 90 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<fruit>[0]<variety>[0]<name>
        ┃   Success   ┃        ~~ "red delicious"
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<fruit>[0]<variety>[1]<name>,
        "granny smith",
        q:to/EOF/
        ♪ [Is expected value?] - 91 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<fruit>[0]<variety>[1]<name>
        ┃   Success   ┃        ~~ "granny smith"
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<fruit>[1]<name>,
        "banana",
        q:to/EOF/
        ♪ [Is expected value?] - 92 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<fruit>[1]<name>
        ┃   Success   ┃        ~~ "banana"
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document.made<fruit>[1]<variety>[0]<name>,
        "plantain",
        q:to/EOF/
        ♪ [Is expected value?] - 93 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document.made<fruit>[1]<variety>[0]<name>
        ┃   Success   ┃        ~~ "plantain"
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-document-hard.made<the><test_string>,
        "You'll hate me after this - #",
        q:to/EOF/
        ♪ [Is expected value?] - 94 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document-hard.made<the><test_string>
        ┃   Success   ┃        ~~ "You'll hate me after this - #"
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document-hard.made<the><hard><test_array>,
        [ "] ", " # "],
        q:to/EOF/
        ♪ [Is expected value?] - 95 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document-hard.made<the><hard><test_array>
        ┃   Success   ┃        ~~ [ "] ", " # "]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document-hard.made<the><hard><test_array2>,
        [ "Test #11 ]proved that", "Experiment #9 was a success" ],
        q:to/EOF/
        ♪ [Is expected value?] - 96 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document-hard.made<the><hard><test_array2>
        ┃   Success   ┃        ~~ [ ... ]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document-hard.made<the><hard><another_test_string>,
        " Same thing, but with a string #",
        q:to/EOF/
        ♪ [Is expected value?] - 97 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document-hard.made<the><hard><another_test_string>
        ┃   Success   ┃        ~~ " Same thing, but with a string #"
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document-hard.made<the><hard><harder_test_string>,
        " And when \"'s are in the string, along with # \"",
        q:to/EOF/
        ♪ [Is expected value?] - 98 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document-hard.made<the><hard><harder_test_string>
        ┃   Success   ┃        ~~ " And when \"'s are in the string, along with # \""
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document-hard.made<the><hard><bit#><what?>,
        "You don't think some user won't do that?",
        q:to/EOF/
        ♪ [Is expected value?] - 99 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document-hard.made<the><hard><bit#><what?>
        ┃   Success   ┃        ~~ "You don't think some user won't do that?"
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document-hard.made<the><hard><bit#><multi_line_array>,
        ["]"],
        q:to/EOF/
        ♪ [Is expected value?] - 100 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document-hard.made<the><hard><bit#><multi_line_array>
        ┃   Success   ┃        ~~ ["]"]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-document-standard.made<title>,
        'TOML Example',
        q:to/EOF/
        ♪ [Is expected value?] - 101 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document-standard.made<title>
        ┃   Success   ┃        ~~ 'TOML Example'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document-standard.made<owner><name>,
        'Tom Preston-Werner',
        q:to/EOF/
        ♪ [Is expected value?] - 102 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document-standard.made<owner><name>
        ┃   Success   ┃        ~~ 'Tom Preston-Werner'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document-standard.made<owner><organization>,
        'GitHub',
        q:to/EOF/
        ♪ [Is expected value?] - 103 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document-standard.made<owner><organization>
        ┃   Success   ┃        ~~ 'GitHub'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document-standard.made<owner><bio>,
        "GitHub Cofounder & CEO\nLikes tater tots and beer.",
        q:to/EOF/
        ♪ [Is expected value?] - 104 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document-standard.made<owner><bio>
        ┃   Success   ┃        ~~ "GitHub Cofounder & CEO\nLikes tater tots and beer."
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document-standard.made<owner><dob>,
        '1979-05-27T07:32:00Z',
        q:to/EOF/
        ♪ [Is expected value?] - 105 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document-standard.made<owner><dob>
        ┃   Success   ┃        ~~ '1979-05-27T07:32:00Z'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document-standard.made<database><server>,
        '192.168.1.1',
        q:to/EOF/
        ♪ [Is expected value?] - 106 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document-standard.made<database><server>
        ┃   Success   ┃        ~~ '192.168.1.1'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document-standard.made<database><ports>,
        [ 8001, 8001, 8002 ],
        q:to/EOF/
        ♪ [Is expected value?] - 107 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document-standard.made<database><ports>
        ┃   Success   ┃        ~~ [ 8001, 8001, 8002 ]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document-standard.made<database><ports>[0],
        8001,
        q:to/EOF/
        ♪ [Is expected value?] - 108 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document-standard.made<database><ports>[0]
        ┃   Success   ┃        == 8001
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document-standard.made<database><ports>[1],
        8001,
        q:to/EOF/
        ♪ [Is expected value?] - 109 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document-standard.made<database><ports>[1]
        ┃   Success   ┃        == 8001
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document-standard.made<database><ports>[2],
        8002,
        q:to/EOF/
        ♪ [Is expected value?] - 110 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document-standard.made<database><ports>[2]
        ┃   Success   ┃        == 8002
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document-standard.made<database><connection_max>,
        5000,
        q:to/EOF/
        ♪ [Is expected value?] - 111 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document-standard.made<database><connection_max>
        ┃   Success   ┃        == 5000
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document-standard.made<database><enabled>,
        True,
        q:to/EOF/
        ♪ [Is expected value?] - 112 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document-standard.made<database><enabled>
        ┃   Success   ┃        ~~ True
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document-standard.made<servers><alpha><ip>,
        '10.0.0.1',
        q:to/EOF/
        ♪ [Is expected value?] - 113 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document-standard.made<servers><alpha><ip>
        ┃   Success   ┃        ~~ '10.0.0.1'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document-standard.made<servers><alpha><dc>,
        'eqdc10',
        q:to/EOF/
        ♪ [Is expected value?] - 114 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document-standard.made<servers><alpha><dc>
        ┃   Success   ┃        ~~ 'eqdc10'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document-standard.made<servers><beta><ip>,
        '10.0.0.2',
        q:to/EOF/
        ♪ [Is expected value?] - 115 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document-standard.made<servers><beta><ip>
        ┃   Success   ┃        ~~ '10.0.0.2'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document-standard.made<servers><beta><dc>,
        'eqdc10',
        q:to/EOF/
        ♪ [Is expected value?] - 116 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document-standard.made<servers><beta><dc>
        ┃   Success   ┃        ~~ 'eqdc10'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document-standard.made<servers><beta><country>,
        '中国',
        q:to/EOF/
        ♪ [Is expected value?] - 117 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document-standard.made<servers><beta><country>
        ┃   Success   ┃        ~~ '中国'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document-standard.made<clients><data>[0][0],
        'gamma',
        q:to/EOF/
        ♪ [Is expected value?] - 118 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document-standard.made<clients><data>[0][0]
        ┃   Success   ┃        ~~ 'gamma'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document-standard.made<clients><data>[0][1],
        'delta',
        q:to/EOF/
        ♪ [Is expected value?] - 119 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document-standard.made<clients><data>[0][1]
        ┃   Success   ┃        ~~ 'delta'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document-standard.made<clients><data>[1][0],
        1,
        q:to/EOF/
        ♪ [Is expected value?] - 120 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document-standard.made<clients><data>[1][0]
        ┃   Success   ┃        == 1
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document-standard.made<clients><data>[1][1],
        2,
        q:to/EOF/
        ♪ [Is expected value?] - 121 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document-standard.made<clients><data>[1][1]
        ┃   Success   ┃        == 2
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document-standard.made<clients><hosts>[0],
        'alpha',
        q:to/EOF/
        ♪ [Is expected value?] - 122 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document-standard.made<clients><hosts>[0]
        ┃   Success   ┃        ~~ 'alpha'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document-standard.made<clients><hosts>[1],
        'omega',
        q:to/EOF/
        ♪ [Is expected value?] - 123 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document-standard.made<clients><hosts>[1]
        ┃   Success   ┃        ~~ 'omega'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document-standard.made<products>[0]<name>,
        'Hammer',
        q:to/EOF/
        ♪ [Is expected value?] - 124 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document-standard.made<products>[0]<name>
        ┃   Success   ┃        ~~ 'Hammer'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document-standard.made<products>[0]<sku>,
        738594937,
        q:to/EOF/
        ♪ [Is expected value?] - 125 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document-standard.made<products>[0]<sku>
        ┃   Success   ┃        == 738594937
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document-standard.made<products>[1]<name>,
        'Nail',
        q:to/EOF/
        ♪ [Is expected value?] - 126 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document-standard.made<products>[1]<name>
        ┃   Success   ┃        ~~ 'Nail'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document-standard.made<products>[1]<sku>,
        284758393,
        q:to/EOF/
        ♪ [Is expected value?] - 127 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document-standard.made<products>[1]<sku>
        ┃   Success   ┃        == 284758393
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-document-standard.made<products>[1]<color>,
        'gray',
        q:to/EOF/
        ♪ [Is expected value?] - 128 of 128
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-document-standard.made<products>[1]<color>
        ┃   Success   ┃        ~~ 'gray'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
});

# end table grammar tests }}}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
