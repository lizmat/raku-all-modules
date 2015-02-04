use v6;

# specification: http://www.w3.org/TR/2011/REC-CSS2-20110607/propidx.html

use CSS::Specification::Terms;
use CSS::Grammar::CSS21;
use CSS::Module::CSS21::Spec::Interface;
use CSS::Module::CSS21::Spec::Grammar;

grammar CSS::Module::CSS21:ver<20110607.000> { ... }

grammar CSS::ModuleX::CSS21:ver<20110607.000>
    is CSS::Module::CSS21::Spec::Grammar {

    token proforma:sym<inherit> {:i inherit}

    # allow color names and define our vocabulary
    rule color:sym<named> {:i [ aqua | black | blue | fuchsia | gray | green | lime | maroon | navy | olive | orange | purple | red | silver | teal | white | yellow ] & <keyw> }

    # system colors are a css2 anachronism
    rule color:sym<system> {:i [ ActiveBorder | ActiveCaption | AppWorkspace | Background | ButtonFace | ButtonHighlight | ButtonShadow | ButtonText | CaptionText | GrayText | Highlight | HighlightText | InactiveBorder | InactiveCaption | InactiveCaptionText | InfoBackground | InfoText | Menu | MenuText | Scrollbar | ThreeDDarkShadow | ThreeDFace | ThreeDHighlight | ThreeDLightShadow | ThreeDShadow | Window | WindowFrame | WindowText ] & <system=.keyw> }
 
    # --- Functions --- #

    rule attr     {:i'attr(' [ <attribute_name=.qname> || <any-args>] ')'}

    rule counter  {:i'counter(' [ <identifier> [ ',' <expr-list-style-type> ]* || <any-args> ] ')'}
    rule counters {:i'counters(' [ <identifier> [ ',' <string> [ ',' <expr-list-style-type> ]* ]? || <any-args> ] ')' }
    rule shape    {:i'rect(' [ [ <length> | auto & <keyw> ]**4 %',' || <any-args> ] ')' }

    # --- Expressions --- #

    rule expr-azimuth {:i <angle>
                           | [ leftwards | rightwards]  & <delta=.keyw>
                           | [:my @*SEEN;
                              [ [left|right][\-side]? | far\-[left|right] | center[\-[left|right]]? ] & <direction=.keyw> <!seen(0)>
                              | behind & <behind=.keyw> <!seen(1)> ]+ }

    rule border-style {:i [ none | hidden | dotted | dashed | solid | double | groove | ridge | inset | outset ] & <keyw> }
    rule border-width {:i [ thin | medium | thick ] & <keyw> | <length> }
    rule expr-counter-increment {:i [ none & <keyw> || [ <identifier> <integer>? ]+ ] }
    rule expr-counter-reset {:i [ none & <keyw> || [ <identifier> <integer>? ]+ ] }
    rule expr-elevation {:i <angle>
                             | [below | level | above ] & <direction=.keyw>
                             | [ higher | lower ] & <tilt=.keyw> }
    rule expr-font-family    {:i  [ <generic-family> || <family-name> ] +% <op(',')> }
    rule family-name    { <family-name=.identifiers> || <family-name=.string> }
    rule generic-family {:i [ serif | sans\-serif | cursive | fantasy | monospace ] & <keyw> }
    rule absolute-size  {:i [ [x[x]?\-]?[small|large] | medium ] & <keyw> }
    rule relative-size  {:i [ larger | smaller ] & <keyw> }
    rule margin-width   {:i <length> | <percentage> | auto & <keyw> }
    rule padding-width  {:i <length> | <percentage> }
    rule generic-voice  {:i [ male | female | child ] & <keyw> }
    rule specific-voice {:i <value=.identifier> | <value=.string> }
    rule expr-voice-family { [ <value=.generic-voice> || <value=.specific-voice> ] +% <op(',')> }
}

grammar CSS::Module::CSS21:ver<20110607.000>
    is CSS::ModuleX::CSS21
    is CSS::Specification::Terms
    is CSS::Grammar::CSS21
    does CSS::Module::CSS21::Spec::Interface {}
