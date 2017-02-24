#!/usr/bin/env perl6

use Test;

use CSS::Module::CSS1;
use CSS::Module::CSS21;
use CSS::Module::CSS3;
use CSS::Grammar::Test;
use CSS::Writer;
use JSON::Fast;

for "012AF", "012AFc" {
    # css21+ unicode is up to 6 digits
    nok $_ ~~ /^<CSS::Module::CSS1::unicode>$/, "not css1 unicode: $_";
    ok  $_ ~~ /^<CSS::Module::CSS21::unicode>$/, "css21 unicode: $_";
    ok  $_ ~~ /^<CSS::Module::CSS3::unicode>$/, "css3 unicode: $_";
}

# css1 and css21 only recognise latin chars as non-ascii (\o240-\o377)
for '' {
    nok $_ ~~ /^<CSS::Module::CSS1::nonascii>$/, "not non-ascii css1: $_";
    nok $_ ~~ /^<CSS::Module::CSS21::nonascii>$/, "not non-ascii css21: $_";
    ok  $_ ~~ /^<CSS::Module::CSS3::nonascii>$/, "non-ascii css3: $_";
}

my $css1  = CSS::Module::CSS1.module;
my $css21 = CSS::Module::CSS21.module;
my $css3  = CSS::Module::CSS3.module;
my $writer = CSS::Writer.new( :terse, :color-names );

for 't/00basic.json'.IO.lines.map({ from-json($_).pairs[0] }) {

    my $rule = .key;
    my %expected = .value;
    my $input = %expected<input>;

    for { :module($css1), },
       	{ :module($css21),},	
       	{ :module($css3), },
       	{ :module($css3), :lax}
    -> % ( :$module!, :$lax=False ) {

        my $suite = $module.name;
        $suite ~= '(lax)' if $lax;
	my $grammar = $module.grammar;
        my $actions = $module.actions.new(:$lax);
        my %level-tests = %( %expected{$suite} // () );
        my %level-expected = %expected, %level-tests;

	    CSS::Grammar::Test::parse-tests($grammar, $input,
					    :$rule,
					    :$suite,
					    :$actions,
                                            :$writer,
					    :expected(%level-expected) );
    }

}

done-testing;
