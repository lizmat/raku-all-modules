use v6;

use CSS::Module::CSS21::Actions;
use CSS::Module::CSS3::Colors;
use CSS::Module::CSS3::Fonts::Actions;
use CSS::Module::CSS3::MediaQueries;
use CSS::Module::CSS3::Namespaces;
use CSS::Module::CSS3::PagedMedia;
use CSS::Module::CSS3::Selectors::Actions;
use CSS::Module::CSS3::_Base::Actions;

class CSS::Module::CSS3::Actions
    is CSS::Module::CSS3::Colors::Actions
    is CSS::Module::CSS3::Fonts::Actions
    is CSS::Module::CSS3::MediaQueries::Actions
    is CSS::Module::CSS3::Namespaces::Actions
    is CSS::Module::CSS3::PagedMedia::Actions
    is CSS::Module::CSS3::Selectors::Actions
    is CSS::ModuleX::CSS21::Actions
    is CSS::Module::CSS3::_Base::Actions {
}
