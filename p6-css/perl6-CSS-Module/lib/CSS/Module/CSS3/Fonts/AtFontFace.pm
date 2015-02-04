use v6;

grammar CSS::Module::CSS3::Fonts::AtFontFace {...}

use CSS::Module::CSS3::Fonts::Variants;
use CSS::Specification::Terms::CSS3;
use CSS::Module::CSS3::Fonts::AtFontFace::Spec::Interface;
use CSS::Module::CSS3::Fonts::AtFontFace::Spec::Grammar;
use CSS::Module::CSS3::Fonts::AtFontFace::Spec::Actions;
use CSS::Grammar::CSS3;

grammar CSS::Module::CSS3::Fonts::AtFontFace
    is CSS::Module::CSS3::Fonts::Variants
    is CSS::Module::CSS3::Fonts::AtFontFace::Spec::Grammar
    is CSS::Specification::Terms::CSS3
    is CSS::Grammar::CSS3
    does CSS::Module::CSS3::Fonts::AtFontFace::Spec::Interface {

    # @font-face declarations

    # ---- Functions ----
    rule format {:i('format')'(' [ <string> | <keyw> || <any-args> ] ')'}
    rule local  {:i('local')'(' [ <font-face-name> || <any-args> ] ')'}
    rule font-face-name { <font-face-name=.identifiers> | <font-face-name=.string> }
    rule family-name    { <family-name=.identifiers> || <family-name=.string> }
}
