#!/usr/bin/env perl6

use Test;
use JSON::Fast;
use CSS::Module::CSS3::Selectors;
use CSS::Module::CSS3::Selectors::Actions;
use CSS::Grammar::Test;

lives-ok {require CSS::Grammar:ver(v0.3.0..*) }, "CSS::Grammar version";
my $actions = CSS::Module::CSS3::Selectors::Actions.new;

for ( 't/00basic.json'.IO.lines ) {
    next 
        if .substr(0,2) eq '//';

    my ($rule, $expected) = @( from-json($_) );
    my $input = $expected<input>;

    CSS::Grammar::Test::parse-tests(CSS::Module::CSS3::Selectors, $input,
				    :$rule,
				    :$actions,
				    :suite<css3x-selectors>,
				    :$expected );
}

done-testing;
