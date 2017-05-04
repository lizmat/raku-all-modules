use v6;
use Test;
plan 2;

use CSS::Declarations;
use CSS::Module::CSS3;
use CSS::Writer;

my $css = CSS::Declarations.new;
my $module = CSS::Module::CSS3.module;
my $actions = $module.actions.new;
my $writer = CSS::Writer.new: :color-names, :terse;

for ("border-bottom-color:red; border-bottom-style:solid; border-bottom-width:1px; border-left-color:red; border-left-style:solid; border-left-width:1px; border-right-color:red; border-right-style:solid; border-right-width:1px; border-top-color:red; border-top-style:solid; border-top-width:1px;" => "border:1px solid red;",
     "border-top-width:5px!important;" => Any,
    ) -> \t {
    my $p = $module.grammar.parse(t.key, :rule<declaration-list>, :$actions)
        // die "unable to parse declarations: {t.key}";

    my $ast = $css.optimize($p.ast);
    is $writer.write(|$ast), (t.value//t.key), "optimise {t.key}";
}

done-testing;
