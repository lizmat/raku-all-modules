#!/usr/bin/env perl6

# these tests check for conformance with error handling as outline in
# http://www.w3.org/TR/2011/REC-CSS2-20110607/syndata.html#parsing-errors

use Test;
use JSON::Fast;

use CSS::Grammar;
use CSS::Grammar::CSS3;
use CSS::Grammar::Actions;
use CSS::Grammar::Test :parse-tests;

my $actions = CSS::Grammar::Actions.new;

for 't/error-handling.json'.IO.lines {
    if .substr(0,2) eq '//' {
##        note '[' ~ .substr(2) ~ ']';
        next;
    }
    my ($rule, $expected) = @( from-json($_) );
    my $input = $expected<input>;

    parse-tests(CSS::Grammar::CSS3, $input,
                :$actions,
                :$rule,
                :suite<css3 errors>,
                :$expected );

}

done-testing;
