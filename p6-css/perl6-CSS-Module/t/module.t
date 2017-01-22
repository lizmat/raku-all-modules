use v6;
use Test;
use CSS::Module::CSS1;
use CSS::Module::CSS21;
use CSS::Module::CSS3;
use CSS::Module::CSS3::Fonts::AtFontFace;

my \css1-module = CSS::Module::CSS1.module;
isa-ok css1-module.grammar, ::('CSS::Module::CSS1'), 'css1 grammar';
isa-ok css1-module.actions, ::('CSS::Module::CSS1::Actions'), 'css1 actions';
my \css1-prop = css1-module.property-metadata;
nok css1-prop<azimuth>:exists, 'css1 does not have azimuth';
is-deeply css1-prop<border>, {:box, :edges["border-top", "border-right", "border-bottom", "border-left"], :children["border-width", "border-style", "border-color"], :!inherit, :synopsis("'border-width' || 'border-style' || 'border-color'")}, 'css1 border';
is-deeply css1-prop<border-style>, {:box, :edges[<border-top-style border-right-style border-bottom-style border-left-style>], :!inherit, :synopsis("[ none | dotted | dashed | solid | double | groove | ridge | inset | outset ]\{1,4}") }, 'css1 border-style';
is-deeply css1-module.parse-property('border-style', 'none' ), [{ :keyw<none> }, ], 'module.parse-property method';
is-deeply css1-module.parse-property('width', '5pt' ), [{ :pt(5) }, ], 'module.parse-property method';

nok css1-module.parse-property('border-style', 'flashy', :!warn), 'module.parse-property failure';

nok css1-module.colors<gold>:exists, "css1 does not have gold color";
is-deeply css1-module.colors<red>, [ 255, 0,   0 ], "colors";

my \css21-module = CSS::Module::CSS21.module;
isa-ok css21-module.grammar, ::('CSS::Module::CSS21'), 'css21 grammar';
isa-ok css21-module.actions, ::('CSS::Module::CSS21::Actions'), 'css21 actions';
my \css21-prop = css21-module.property-metadata;
ok css21-prop<azimuth>:exists, 'css21 has azimuth';
is-deeply css21-prop<border>, {:box, :children["border-width", "border-style", "border-color"], :edges["border-top", "border-right", "border-bottom", "border-left"], :!inherit, :synopsis("[ 'border-width' || 'border-style' || 'border-color' ]")}, 'css21 border';
is-deeply css21-prop<border-style>, {:box, :edges[<border-top-style border-right-style border-bottom-style border-left-style>], :!inherit, :synopsis("<border-style>\{1,4}") }, 'css21 border-style';

nok css21-module.colors<gold>:exists, "css21 does not have gold color";
is-deeply css21-module.colors<red>, [ 255, 0,   0 ], "colors";

my \css3-module = CSS::Module::CSS3.module;
is css3-module.name, 'CSS3', 'module.name';
isa-ok css3-module.grammar, ::('CSS::Module::CSS3'), 'css3 grammar';
isa-ok css3-module.actions, ::('CSS::Module::CSS3::Actions'), 'css3 actions';
my \css3-prop = css3-module.property-metadata;
is-deeply css3-prop<azimuth>, {:default["center", [{:keyw<center>},]], :inherit, :synopsis("<angle> | [[ left-side | far-left | left | center-left | center | center-right | right | far-right | right-side ] || behind ] | leftwards | rightwards")}, 'css3 azimuth';
is-deeply css3-prop<border>, {:box, :children["border-width", "border-style", "border-color"], :edges["border-top", "border-right", "border-bottom", "border-left"], :!inherit, :synopsis("[ 'border-width' || 'border-style' || 'border-color' ]")}, 'css3 border';
is-deeply css3-prop<border-style>, {:box, :edges[<border-top-style border-right-style border-bottom-style border-left-style>], :!inherit, :synopsis("<border-style>\{1,4}") }, 'css3 border-style';

is-deeply css3-module.colors<gold>, [ 255, 215,   0 ], "colors";

my \at-fontface-module = css3-module.sub-module<@font-face>;
isa-ok at-fontface-module.grammar, ::('CSS::Module::CSS3::Fonts::AtFontFace'), '@font-face grammar';
isa-ok at-fontface-module.actions, ::('CSS::Module::CSS3::Actions'), '@font-face actions';
my \at-fontface-prop = at-fontface-module.property-metadata;
is-deeply at-fontface-prop<font-style>, { :synopsis("normal | italic | oblique"), :default["normal", [{:keyw("normal")},]], }, '@font-face font-style';

done-testing;
