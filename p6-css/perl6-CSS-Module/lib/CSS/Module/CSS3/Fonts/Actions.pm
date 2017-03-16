use v6;

use CSS::Module::CSS3::_Base::Actions;
use CSS::Module::CSS3::Fonts::Variants;
use CSS::Module::CSS3::Fonts::Spec::Actions;
use CSS::Module::CSS3::Fonts::AtFontFace::Spec::Interface;
use CSS::Module::CSS3::Fonts::Spec::Interface;
use CSS::Module::CSS3::Fonts::AtFontFace::Spec::Actions;

class CSS::Module::CSS3::Fonts::Actions
    is CSS::Module::CSS3::_Base::Actions
    is CSS::Module::CSS3::Fonts::Variants::Actions
    is CSS::Module::CSS3::Fonts::Spec::Actions
    is CSS::Module::CSS3::Fonts::AtFontFace::Spec::Actions
    does CSS::Module::CSS3::Fonts::Spec::Interface
    does CSS::Module::CSS3::Fonts::AtFontFace::Spec::Interface {

    use CSS::Grammar::AST :CSSObject;

    method at-rule:sym<font-face>($/) { make $.at-rule($/) }

    method format($/) {
        return $.warning("usage: format(type)")
            if $<any-args>;

        make $.func( $0.lc, $.list($/) );
    }

    method local($/) {
        return $.warning("usage: local(font-face-name)")
            if $<any-args>;

        make $.func( $0.lc, $.list($/) );
    }

    method font-description($/)   { make $<declarations>.ast }
    method font-variant-css21($/) { make $.token($.list($/), :type<expr:font-variant>) }
    method src($/)                { make $.node($/) }

}
