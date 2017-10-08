#!/usr/bin/env perl6

use Test;
use CSS::Grammar::Test;
use CSS::Grammar::CSS21;
use CSS::Specification::Build;

sub capture($code, $output-path?) {
    my $output;

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

my $base-name = 't::CSS::Aural::Spec';
my $grammar-name = $base-name ~ '::Grammar';
my $actions-name = $base-name ~ '::Actions';
my $interface-name = $base-name ~ '::Interface';

my $input-path = $*SPEC.catfile('examples', 'css21-aural.txt');
my @summary = CSS::Specification::Build::summary( :$input-path );
is +@summary, 25, 'number of summary items';
is-deeply [@summary.grep({ .<box> })], [{:box, :!inherit, :name<border-color>, :edges["border-top-color", "border-right-color", "border-bottom-color", "border-left-color"], :synopsis("[ <color> | transparent ]\{1,4}")},], 'summary item';

capture({
    CSS::Specification::Build::generate( 'grammar', $grammar-name, :$input-path );
}, 'lib/t/CSS/Aural/Spec/Grammar.pm');
lives-ok {require ::($grammar-name)}, "$grammar-name compilation";

capture({
    CSS::Specification::Build::generate( 'actions', $actions-name, :$input-path );
}, 'lib/t/CSS/Aural/Spec/Actions.pm');
lives-ok {require ::($actions-name)}, "$actions-name compilation";

capture({
    CSS::Specification::Build::generate( 'interface', $interface-name, :$input-path );
}, 'lib/t/CSS/Aural/Spec/Interface.pm');
lives-ok {require ::($interface-name)}, "$interface-name compilation";

dies-ok {require ::("t::CSS::Aural::BadGrammar")}, 'grammar composition, unimplemented interface - dies';

my $aural-class;
lives-ok {$aural-class = (require ::("t::CSS::Aural::Grammar"))}, 'grammar composition - lives';
isa-ok $aural-class, CSS::Grammar::CSS21;

my $actions;
lives-ok {$actions = (require ::("t::CSS::Aural::Actions")).new}, 'class composition - lives';
ok $actions.defined, '::("t::CSS::Aural::Actions").new';

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
done-testing;
