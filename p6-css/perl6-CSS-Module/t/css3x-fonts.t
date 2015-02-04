#!/usr/bin/env perl6

use Test;
use JSON::Tiny;

use CSS::Module::CSS3::Fonts;
use CSS::Module::CSS21::Actions;
use CSS::Module::CSS21;
use CSS::Grammar::Test;
use CSS::Writer;

my $css3x-actions = CSS::Module::CSS3::Fonts::Actions.new;
my $css21-actions = CSS::Module::CSS21::Actions.new;
my $writer = CSS::Writer.new;

for 't/css3x-fonts.json'.IO.lines {

    next if .substr(0,2) eq '//';

    my ($rule, $expected) = @( from-json($_) );

    my $input = $expected<input>;

    CSS::Grammar::Test::parse-tests( CSS::Module::CSS3::Fonts, $input,
				     :$rule,
				     :actions($css3x-actions),
                                     :$writer,
				     :suite<css3x-fonts>,
				     :$expected );

    my $css21 = $expected<css21> // {};
    CSS::Grammar::Test::parse-tests(CSS::Module::CSS21, $input,
				    :$rule,
				    :actions($css21-actions),
				    :suite<css21>,
                                    :$writer,
				    :expected(%(%$expected, %$css21)) );
}

done;
