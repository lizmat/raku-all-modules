use v6;
use CSS::Aural::Spec::Actions;
use CSS::Grammar::Actions;
use CSS::Specification::Terms::Actions;
use CSS::Aural::Spec::Interface;

class CSS::Aural::Actions
    is CSS::Aural::Spec::Actions
    is CSS::Specification::Terms::Actions
    is CSS::Grammar::Actions
    does CSS::Aural::Spec::Interface {

    method proforma:sym<inherit>($/) { make {'keyw' => ~$<sym>} }
}
