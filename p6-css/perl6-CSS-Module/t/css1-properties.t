#!/usr/bin/env perl6

use Test;
use JSON::Tiny;

use CSS::Module::CSS1::Actions;
use CSS::Module::CSS1;
use CSS::Module::CSS21::Actions;
use CSS::Module::CSS21;
use CSS::Module::CSS3;
use CSS::Grammar::Test;
use CSS::Writer;

my $css1-actions  = CSS::Module::CSS1::Actions.new;
my $css21-actions = CSS::Module::CSS21::Actions.new;
my $css3x-actions = CSS::Module::CSS3::Actions.new;
my $css-writer = CSS::Writer.new;

my %seen;

for 't/css1-properties.json'.IO.lines {

    next if .substr(0,2) eq '//';

    my %expected = %( from-json($_) );
    my $prop = %expected<prop>.lc;
    my $input = sprintf '{%s: %s}', $prop, %expected<decl>;
    my $expr = %expected<expr>;

    %expected<ast> = $expr ?? { :declarations[{ :property{ :ident($prop), :$expr } }] } !! Any;

    for css1  => {class => CSS::Module::CSS1,  actions => $css1-actions,  proforma => qw<>},
       	css21 => {class => CSS::Module::CSS21, actions => $css21-actions, proforma => qw<inherit>},	
       	css3x => {class => CSS::Module::CSS3,  actions => $css3x-actions, proforma => qw<inherit initial>, writer => $css-writer} {

        my ($level, $opt) = .kv;
        my $class = $opt<class>;
        my $actions = $opt<actions>;
        my $proforma = $opt<proforma>;
        my $writer = $opt<writer>;

	CSS::Grammar::Test::parse-tests($class, $input,
					:rule<declarations>,
					:suite($level),
					:$actions,
                                        :$writer,
					:%expected );

	unless %seen{$prop}{$level}++ {
	    # usage and inheritence  tests
	    my $junk = sprintf '{%s: %s}', $prop, 'junk +-42';

	    $actions.reset;
	    my $p = $class.parse( $junk, :rule<declarations>, :$actions);
	    ok($p.defined && ~$p eq $junk, "$level $prop: able to parse unexpected input")
	        or note "unable to parse declaration list: $junk";

	    ok($actions.warnings, "$level $prop: unexpected input produces warning")
		or diag $actions.warnings;

	    for @$proforma -> $misc {
		my $decl = sprintf '{%s: %s}', $prop, $misc;

		my $ast = { :declarations[{ :property{ :ident($prop), :expr[ { :keyw($misc)} ] } }] };

                CSS::Grammar::Test::parse-tests($class, $decl,
						:rule<declarations>,
						:$actions,
						:suite($level),
						:expected({ast => $ast}) );

            }
        }
    }
}

done;
