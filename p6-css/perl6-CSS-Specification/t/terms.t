use v6;
use Test;
use CSS::Grammar::CSS3;
use CSS::Grammar::Actions;
use CSS::Grammar::Test;

use CSS::Specification::Terms::CSS3;
use CSS::Specification::Terms::CSS3::Actions;

class CSS3Terms
    is CSS::Specification::Terms:CSS3
    is CSS::Grammar::CSS3 {};

class CSS3Terms::Actions
    is CSS::Specification::Terms::CSS3::Actions
    is CSS::Grammar::Actions {};

for '0%' {
    nok($_ ~~ /^<CSS3Terms::number>/, "not number: $_");
    ok($_ ~~ /^<CSS3Terms::percentage>/, "percentage: $_");
    nok($_ ~~ /^<CSS3Terms::angle>/, "not angle: $_");
}

for '0deg' {
    nok($_ ~~ /^<CSS3Terms::number>/, "not number: $_");
    nok($_ ~~ /^<CSS3Terms::percentage>/, "not percentage: $_");
    ok($_ ~~ /^<CSS3Terms::angle>/, "angle: $_");
}

for '0' {
    ok($_ ~~ /^<CSS3Terms::number>/, "number: $_");
    nok($_ ~~ /^<CSS3Terms::percentage>/, "not percentage: $_");
    ok($_ ~~ /^<CSS3Terms::angle>/, "angle: $_");
}

for '1' {
    ok($_ ~~ /^<CSS3Terms::number>/, "number: $_");
    nok($_ ~~ /^<CSS3Terms::percentage>/, "not percentage: $_");
    nok($_ ~~ /^<CSS3Terms::angle>/, "angle: $_");
}

my $actions = CSS3Terms::Actions.new;

for :number<123.45>        => :num(123.45),
    :integer<123>          => :int(123),
    :uri("url(foo.jpg)")   => :url<foo.jpg>,
    :keyw<Abc>             => :keyw<abc>,
    :identifier<Foo>       => :ident<Foo>,
    :identifiers("Aaa bb") => :ident("Aaa bb") {

    my ($in, $ast) = .kv;
    my ($rule, $input) = $in.kv;

    my %expected = :$ast;

    CSS::Grammar::Test::parse-tests(CSS3Terms, $input,
                                    :$actions,
                                    :$rule,
                                    :suite('css3 terms'),
                                    :%expected);
}

done;
