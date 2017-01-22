#!/usr/bin/env perl6

use Test;
use JSON::Fast;

use CSS::Module::CSS21;
use CSS::Module::CSS3;
use CSS::Module::CSS1;
use CSS::Grammar::Test;
use CSS::Writer;

my $css1  = CSS::Module::CSS1.module;
my $css21 = CSS::Module::CSS21.module;
my $css3x = CSS::Module::CSS3.module;

my $css-writer = CSS::Writer.new;

my %seen;

for 't/css1-properties.json'.IO.lines {

    next if .substr(0,2) eq '//';

    my %expected = %( from-json($_) );
    my $prop = %expected<prop>.lc;
    my $input = sprintf '{%s: %s}', $prop, %expected<decl>;
    my $expr = %expected<expr>;

    %expected<ast> = $expr ?? { :declarations[{ :property{ :ident($prop), :$expr } }] } !! Any;

    for css1  => {module => $css1, proforma => qw<>},
       	css21 => {module => $css21, proforma => qw<inherit>},	
       	css3x => {module => $css3x, proforma => qw<inherit initial>, writer => $css-writer} {

        my ($level, $opt) = .kv;
        my $module = $opt<module>;
        my $grammar = $module.grammar;
        my $actions = $module.actions.new;
        my $proforma = $opt<proforma>;
        my $writer = $opt<writer>;

	CSS::Grammar::Test::parse-tests($grammar, $input,
					:rule<declarations>,
					:suite($level),
					:$actions,
                                        :$writer,
					:%expected );

	unless %seen{$prop}{$level}++ {
	    # usage and inheritence  tests
	    my $junk = sprintf '{%s: %s}', $prop, 'junk +-42';

	    $actions.reset;
	    my $p = $grammar.parse( $junk, :rule<declarations>, :$actions);
	    ok($p.defined && ~$p eq $junk, "$level $prop: able to parse unexpected input")
	        or note "unable to parse declaration list: $junk";

	    ok($actions.warnings, "$level $prop: unexpected input produces warning")
		or diag $actions.warnings;

	    for @$proforma -> $misc {
		my $decl = sprintf '{%s: %s}', $prop, $misc;

		my $ast = { :declarations[{ :property{ :ident($prop), :expr[ { :keyw($misc)} ] } }] };

                CSS::Grammar::Test::parse-tests($grammar, $decl,
						:rule<declarations>,
						:$actions,
						:suite($level),
						:expected({ :$ast }) );

            }
        }
    }
}

done-testing;
