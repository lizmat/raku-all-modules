
use CSS::Aural::Spec::Grammar;
use CSS::Aural::Spec::Interface;
use CSS::Grammar::CSS21;
use CSS::Specification::Terms;

grammar CSS::Aural::Grammar
    is CSS::Aural::Spec::Grammar 
    is CSS::Specification::Terms
    is CSS::Grammar::CSS21
    does CSS::Aural::Spec::Interface {

    rule proforma:sym<inherit> { <sym> }
}
