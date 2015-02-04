use v6;

# references:
# -- http://www.w3.org/TR/2008/REC-CSS1-20080411/#css1-properties
# -- http://129.69.59.141/css1pqre.htm

use CSS::Specification::Terms;
use CSS::Grammar::CSS1;
# BUILD.pl targets
use CSS::Module::CSS1::Spec::Interface;
use CSS::Module::CSS1::Spec::Grammar;

grammar CSS::Module::CSS1:ver<20080411.000>
    is CSS::Specification::Terms
    is CSS::Grammar::CSS1
    is CSS::Module::CSS1::Spec::Grammar
    does CSS::Module::CSS1::Spec::Interface {

        # tweak generated font-family expression.
        rule expr-font-family    {:i  [ <generic-family> || <family-name> ] +% <op(',')> }

        # allow color names and define our vocabulary
        rule color:sym<named>  {:i [aqua | black | blue | fuchsia | gray | green | lime | maroon | navy | olive | purple | red | silver | teal | white | yellow] & <keyw> }

        rule family-name    { <family-name=.identifiers> || <family-name=.string> }
        rule generic-family {:i [ serif | sans\-serif | cursive | fantasy | monospace ] & <keyw> }

        rule absolute-size {:i [ [x[x]?\-]?[small|large] | medium ] & <keyw> }
        rule relative-size {:i [ larger | smaller ] & <keyw> }

        rule padding-width {:i <length> | <percentage> }
}
