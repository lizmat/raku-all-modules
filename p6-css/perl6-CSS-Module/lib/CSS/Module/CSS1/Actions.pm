use v6;

use CSS::Specification::Terms::Actions;
use CSS::Grammar::Actions;
# BUILD.pl targets
use CSS::Module::CSS1::Spec::Interface;
use CSS::Module::CSS1::Spec::Actions;

class CSS::Module::CSS1::Actions
    is CSS::Specification::Terms::Actions
    is CSS::Module::CSS1::Spec::Actions
    is CSS::Grammar::Actions
    does CSS::Module::CSS1::Spec::Interface {
}

