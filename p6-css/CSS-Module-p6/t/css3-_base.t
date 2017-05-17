use v6;
use Test;
use CSS::Grammar::Test;

use CSS::Module::CSS3::_Base;
use CSS::Module::CSS3::_Base::Actions;

class CSS3Terms
    is CSS::Module::CSS3::_Base {};

class CSS3Terms::Actions
    is CSS::Module::CSS3::_Base::Actions {};

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

done-testing;
