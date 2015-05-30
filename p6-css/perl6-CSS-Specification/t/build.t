#!/usr/bin/env perl6

use Test;
use CSS::Grammar::Test;
use CSS::Specification::Build;

sub pipe($input-path, $code, $output-path?) {
    my $output;

    my $*IN = open $input-path, :r;
    my $*OUT = $output-path
        ?? open $output-path, :w
        !! class {
            method print(*@args) {
                $output ~= @args.join;
            }
            multi method write(Buf $b){$output ~= $b.decode}
        }

    $code();

    return $output-path // $output;
}

use lib 't';

my $base-name = 'CSS::Aural::Spec';
my $grammar-name = $base-name ~ '::Grammar';
my $actions-name = $base-name ~ '::Actions';
my $interface-name = $base-name ~ '::Interface';

my $input-path = $*SPEC.catfile('examples', 'css21-aural.txt' );
my @summary = CSS::Specification::Build::summary( :$input-path );
is +@summary, 21, 'number of summary items';
is-deeply [@summary.grep({ .<box> })], [{:box, :!inherit, :name<border-color>, :synopsis("[ <color> | transparent ]\{1,4}")}], 'summary item';

pipe( $input-path, {
    CSS::Specification::Build::generate( 'grammar', $grammar-name );
}, 't/CSS/Aural/Spec/Grammar.pm');
lives-ok {EVAL "use $grammar-name"}, 'grammar compilation';

pipe( $input-path, {
    CSS::Specification::Build::generate( 'actions', $actions-name );
}, 't/CSS/Aural/Spec/Actions.pm');
lives-ok {EVAL "use $actions-name"}, 'actions compilation';

my $aural-interface-code = pipe( $input-path, {
    CSS::Specification::Build::generate( 'interface', $interface-name );
}, 't/CSS/Aural/Spec/Interface.pm');
lives-ok {EVAL "use $interface-name"}, 'interface compilation';

dies-ok {EVAL 'use CSS::Aural::BadGrammar'}, 'grammar composition, unimplemented interface - dies';

my $aural-class;
lives-ok {EVAL "use CSS::Aural::Grammar; \$aural-class = CSS::Aural::Grammar"}, 'grammar composition - lives';

my $actions;
lives-ok {EVAL "use CSS::Aural::Actions; \$actions = CSS::Aural::Actions.new"}, 'class composition - lives';

for ('.aural-test { stress: 42; speech-rate: fast; volume: inherit; voice-family: female; }' =>
     {ast => { :stylesheet[
               :ruleset{
                   :selectors[ :selector[ :simple-selector[ :class<aural-test> ] ] ],
                   :declarations[
                       :property{ :ident<stress>, :expr[{ :num(42) }] },
                       :property{ :ident<speech-rate>, :expr[{ :keyw<fast> }] },
                       :property{ :ident<volume>, :expr[{ :keyw<inherit> }] },
                       :property{ :ident<voice-family>, :expr[{ :keyw<female> }] },
                       ],
                    }
                   ]}
      },
     '.boxed-test { border-color: #aaa }' =>
     {ast => { :stylesheet[
                    :ruleset{
                        :selectors[ :selector[ :simple-selector[{:class<boxed-test>}] ]],
                        :declarations[ :property{
                            :ident<border-color>,
                            :expr[{ :rgb[ :num(170), :num(170), :num(170) ]}]}],
                    }
                   ]}
     },
    ) {
    my ($input, $expected) = .kv;

    CSS::Grammar::Test::parse-tests($aural-class, $input, 
                                    :$actions, :$expected);
}
done;
