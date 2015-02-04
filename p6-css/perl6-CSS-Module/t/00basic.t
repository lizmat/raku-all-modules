#!/usr/bin/env perl6

use Test;

use CSS::Module::CSS1::Actions;
use CSS::Module::CSS1;
use CSS::Module::CSS21::Actions;
use CSS::Module::CSS21;
use CSS::Module::CSS3;
use CSS::Grammar::Test;
use CSS::Writer;

for ("012AF", "012AFc") {
    # css21+ unicode is up to 6 digits
    nok($_ ~~ /^<CSS::Module::CSS1::unicode>$/, "not css1 unicode: $_");
    ok($_ ~~ /^<CSS::Module::CSS21::unicode>$/, "css21 unicode: $_");
    ok($_ ~~ /^<CSS::Module::CSS3::unicode>$/, "css3 unicode: $_");
}

# css1 and css21 only recognise latin chars as non-ascii (\o240-\o377)
for ('') {
    nok($_ ~~ /^<CSS::Module::CSS1::nonascii>$/, "not non-ascii css1: $_");
    nok($_ ~~ /^<CSS::Module::CSS21::nonascii>$/, "not non-ascii css21: $_");
    ok($_ ~~ /^<CSS::Module::CSS3::nonascii>$/, "non-ascii css3: $_");
}

my $css1-actions  = CSS::Module::CSS1::Actions.new;
my $css21-actions = CSS::Module::CSS21::Actions.new;
my $css3-actions  = CSS::Module::CSS3::Actions.new;
my $css3-actions_2  = CSS::Module::CSS3::Actions.new( :pass-unknown );
my $css-writer = CSS::Writer.new( :terse, :color-names );

for 't/00basic.json'.IO.lines.map({ from-json($_).list }) {

    my $rule = .key;
    my %expected = %( .value );
    my $input = %expected<input>;

    for css1  => {class => CSS::Module::CSS1,  actions => $css1-actions, writer => $css-writer},
       	css21 => {class => CSS::Module::CSS21, actions => $css21-actions, writer => $css-writer},	
       	css3  => {class => CSS::Module::CSS3,  actions => $css3-actions, writer => $css-writer},
       	pass-unknown  => {class => CSS::Module::CSS3,  actions => $css3-actions_2, writer => $css-writer} {

	    my ($level, $opt) = .kv;
            my $class = $opt<class>;
            my $actions = $opt<actions>;
            my $writer = $opt<writer>;
            my %level-tests = %( %expected{$level} // () );
            my %level-expected = %expected, %level-tests;

	    CSS::Grammar::Test::parse-tests($class, $input,
					    :$rule,
					    :suite($level),
					    :$actions,
                                            :$writer,
					    :expected(%level-expected) );
    }

}

done;
