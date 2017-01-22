use v6;

# CSS3 Font Extension Module
# specification: http://www.w3.org/TR/2013/WD-css3-fonts-20130212/
#
# nb this standard is under revision (as of Feb 2013). Biggest change
# is the proposed at-rule @font-feature-values

use CSS::Module::CSS3::Fonts::AtFontFace;
use CSS::Module::CSS3::Fonts::Variants;
use CSS::Module::CSS3::_Base;
use CSS::Module::CSS3::_Base::Actions;

use CSS::Module::CSS3::Fonts::Spec::Interface;
use CSS::Module::CSS3::Fonts::Spec::Grammar;
use CSS::Module::CSS3::Fonts::Spec::Actions;
use CSS::Module::CSS3::Fonts::AtFontFace::Spec::Interface;
use CSS::Module::CSS3::Fonts::AtFontFace::Spec::Actions;

grammar CSS::Module::CSS3::Fonts:ver<20130212.000> 
    is CSS::Module::CSS3::Fonts::Variants
    is CSS::Module::CSS3::Fonts::Spec::Grammar
    is CSS::Module::CSS3::_Base
    does CSS::Module::CSS3::Fonts::Spec::Interface {

    rule font-description {<declarations=.CSS::Module::CSS3::Fonts::AtFontFace::declarations>}
    rule at-rule:sym<font-face> {\@(:i'font-face') <font-description> }
}

# ----------------------------------------------------------------------

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

