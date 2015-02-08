#!/usr/bin/env perl6

use Test;
use JSON::Tiny;

use CSS::Grammar::CSS3;
use CSS::Grammar::Actions;
use CSS::Grammar::Test;

my $actions = CSS::Grammar::Actions.new( :lax );

for ( 't/css3-syntax.json'.IO.lines ) {
    next 
        if .substr(0,2) eq '//';

    my ($rule, $expected) = @( from-json($_) );
    my @inputs = @( $expected<input> );

    for @inputs -> $input {
        CSS::Grammar::Test::parse-tests(CSS::Grammar::CSS3, $input,
                                        :$rule,
                                        :$actions,
                                        :suite<css3>,
                                        :$expected );
    }
}

done;
