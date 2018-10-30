use Test;

use Grammar::Highlighter;
use Grammar::Highlighter::Terminal;
use Grammar::Highlighter::HTML;

grammar Foo {
    rule TOP {
        <directive>+
    }
    rule directive {
        [
            <foo>
            | <bar>
        ]
        ';'
    }
    rule foo {
        '<Foo>' <baz>
    }
    rule bar {
        Bar <baz>
    }
    token baz {
        Baz
    }
}

my $parser = Foo.new;
my $terminal = Grammar::Highlighter.new(:formatter(Grammar::Highlighter::Terminal.new));

is($parser.parse(q:heredoc/INPUT/, :actions($terminal)).ast.Str, qq:heredoc/OUTPUT/.chomp);
    <Foo> Baz;
    <Foo> Baz;
    Bar Baz;
    INPUT
    \x[1b][31m\x[1b][7m\x[1b][4m<Foo> \x[1b][1mBaz\x[1b][0m\x[1b][0m;
    \x[1b][0m\x[1b][7m\x[1b][4m<Foo> \x[1b][1mBaz\x[1b][0m\x[1b][0m;
    \x[1b][0m\x[1b][7m\x[1b][30mBar \x[1b][1mBaz\x[1b][0m\x[1b][0m;
    \x[1b][0m\x[1b][0m
    OUTPUT

my $html = Grammar::Highlighter.new(:formatter(Grammar::Highlighter::HTML.new));

is($parser.parse(q:heredoc/INPUT/, :actions($html)).ast.Str, q:heredoc/OUTPUT/.chomp);
    <Foo> Baz;
    <Foo> Baz;
    Bar Baz;
    INPUT
    <span style="color: green;"><span style="color: fuchsia;"><span style="color: blue;">&lt;Foo> <span style="color: aqua;">Baz</span></span>;
    </span><span style="color: fuchsia;"><span style="color: blue;">&lt;Foo> <span style="color: aqua;">Baz</span></span>;
    </span><span style="color: fuchsia;"><span style="color: gray;">Bar <span style="color: aqua;">Baz</span></span>;
    </span></span>
    OUTPUT

done-testing;

# vim: ft=perl6
