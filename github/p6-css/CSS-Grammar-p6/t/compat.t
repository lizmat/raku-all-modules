#!/usr/bin/env perl6

# general compatibility tests
# -- css1 is a subset of css2.1 and sometimes parses differently
# -- css3 without extensions should be largely css2.1 compatibile
# -- the core grammar should parse identically to css2.1 and css3

use Test;
use JSON::Fast;

use CSS::Grammar::Test :parse-tests;
use CSS::Grammar::CSS1;
use CSS::Grammar::CSS21;
use CSS::Grammar::CSS3;
use CSS::Grammar::Actions;

my $actions = CSS::Grammar::Actions.new;

for 't/compat.json'.IO.lines {
    if .substr(0,2) eq '//' {
##        note '[' ~ .substr(2) ~ ']';
        next;
    }
    my ($rule, $test) = @( from-json($_) );
    my $input = $test<input>;

    for css1  => {parser => CSS::Grammar::CSS1},
        css21 => {parser => CSS::Grammar::CSS21},
        css3  => {parser => CSS::Grammar::CSS3} {

	my ($level, $opts) = .kv;
        my $class = $opts<parser>;
        my $writer = $opts<writer>;
	my %level-tests = %( $test{$level} // () );
	my %expected = %$test, %level-tests;

	$actions.reset;

	if %expected<skip> {
	    skip $rule ~ ': ' ~ %expected<skip>;
	    next;
	}

	parse-tests($class, $input,
                    :$actions,
                    :$rule,
                    :suite($level),
                    :$writer,
                    :%expected);
    }

    if CSS::Grammar::Core.can( '_' ~ $rule ) {
        my %core-tests = $test<core> // {};
	my %expected = %$test, ast => Any, warnings => Any, %core-tests;
        %expected<warnings> //= Any;
        parse-tests(CSS::Grammar::Core, $input,
                    :$actions,
                    :rule('_' ~ $rule),
                    :suite<core>,
                    :%expected);
    }
}

done-testing;
