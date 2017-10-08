
use t::CSS::Aural::Spec::Grammar;
use t::CSS::Aural::Spec::Interface;
use CSS::Specification::Terms;
use CSS::Grammar::CSS21;

grammar t::CSS::Aural::Grammar
    is t::CSS::Aural::Spec::Grammar 
    is CSS::Specification::Terms
    is CSS::Grammar::CSS21
    does t::CSS::Aural::Spec::Interface {

    rule proforma:sym<inherit> { <sym> }
}
