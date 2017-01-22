#!/usr/bin/env perl6

# these tests check for conformance with error handling as outline in
# http://www.w3.org/TR/2011/REC-CSS2-20110607/syndata.html#parsing-errors

use Test;
use JSON::Fast;

use CSS::Module::CSS3;
use CSS::Grammar::Test;
use CSS::Writer;

my $grammar = CSS::Module::CSS3.module.grammar;
my $actions = CSS::Module::CSS3.module.actions.new;
my $writer  = CSS::Writer.new;

for ( 't/error-handling.json'.IO.lines ) {
    next 
        if .substr(0,2) eq '//';

    my ($rule, $expected) = @( from-json($_) );
    my $input = $expected<input>;

    CSS::Grammar::Test::parse-tests($grammar, $input,
				    :$rule,
				    :$actions,
				    :suite<css3>,
                                    :$writer,
				    :$expected );
}

done-testing;
