use v6;
use t::CSS::Aural::Spec::Actions;
use t::CSS::Aural::Spec::Interface;
use CSS::Specification::Terms::Actions;
use CSS::Grammar::Actions;

class t::CSS::Aural::Actions
    is t::CSS::Aural::Spec::Actions
    is CSS::Specification::Terms::Actions
    is CSS::Grammar::Actions
    does t::CSS::Aural::Spec::Interface {

    method proforma:sym<inherit>($/) { make {'keyw' => ~$<sym>} }
}
