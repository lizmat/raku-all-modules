use v6;
use Test;
plan 9;

use CSS::Declarations;
use CSS::Module;
use CSS::Module::CSS1;
use CSS::Module::CSS21;
use CSS::Module::CSS3;

my $style = 'color: red; azimuth: left';
my CSS::Module $module = CSS::Module::CSS1.module;
my $css1 = CSS::Declarations.new( :$style, :$module, :!warn);
dies-ok { $css1.info("azimuth") }, "azimuth is unknown in CSS1";
is $css1.warnings, "dropping unknown property: azimuth", 'CSS1 warnings';

$module = CSS::Module::CSS21.module;
my $css21 = CSS::Declarations.new( :$style, :$module);
lives-ok { $css21.info("azimuth") }, "azimuth is known in CSS21";
is $css21.warnings, "", 'CSS21 warnings';

$module = CSS::Module::CSS3.module;
my $css3 = CSS::Declarations.new( :$style, :$module);
lives-ok { $css3.info("azimuth") }, "azimuth is known in CSS3";
is $css21.warnings, "", 'CSS3 warnings';

$style = 'src: url(gentium.ttf); azimuth: left';
$module = CSS::Module::CSS3.module.sub-module<@font-face>;
my $css-fontface = CSS::Declarations.new( :$style, :$module, :!warn);
lives-ok { $css-fontface.info("src") }, 'src is known in @font-face';
dies-ok { $css-fontface.info("azimuth") }, 'azimuth is unknown in @font-face';
is $css-fontface.warnings, "dropping unknown property: azimuth", '@fontface warnings';

done-testing;
