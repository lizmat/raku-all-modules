use v6;

# CSS3 Font Extension Module
# specification: http://www.w3.org/TR/2013/WD-css3-fonts-20130212/
#
# nb this standard is under revision (as of Feb 2013). Biggest change
# is the proposed at-rule @font-feature-values

use CSS::Module::CSS3::Fonts::AtFontFace;
use CSS::Module::CSS3::Fonts::Variants;
use CSS::Module::CSS3::_Base;

use CSS::Module::CSS3::Fonts::Spec::Interface;
use CSS::Module::CSS3::Fonts::Spec::Grammar;
use CSS::Module::CSS3::Fonts::AtFontFace::Spec::Interface;

grammar CSS::Module::CSS3::Fonts #:api<css3-fonts-20130212> 
    is CSS::Module::CSS3::Fonts::Variants
    is CSS::Module::CSS3::Fonts::Spec::Grammar
    is CSS::Module::CSS3::_Base
    does CSS::Module::CSS3::Fonts::Spec::Interface {

    rule font-description {<declarations=.CSS::Module::CSS3::Fonts::AtFontFace::declarations>}
    rule at-rule:sym<font-face> {\@(:i'font-face') <font-description> }
}

# ----------------------------------------------------------------------

