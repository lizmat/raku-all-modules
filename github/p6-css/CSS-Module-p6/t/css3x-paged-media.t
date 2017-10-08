#!/usr/bin/env perl6

use Test;
use JSON::Fast;

use CSS::Module::CSS3;
use CSS::Grammar::Test;
use CSS::Writer;

my $grammar = CSS::Module::CSS3.module.grammar;
my $actions = CSS::Module::CSS3.module.actions.new;
my $writer = CSS::Writer.new;

for ( 't/css3x-paged-media.json'.IO.lines ) {
    next
        if .substr(0,2) eq '//';

    my ($rule, $expected) = @( from-json($_) );
    my $input = $expected<input>;

    CSS::Grammar::Test::parse-tests($grammar, $input,
				    :$rule,
				    :$actions,
				    :suite<css3 @page>,
                                    :$writer,
				    :$expected );
}

done-testing;
