use v6;
use Test;
plan 45;
use PDF::Grammar::Test :is-json-equiv;
use PDF::Content::Font;
use PDF::Content::Font::CoreFont;

is PDF::Content::Font::CoreFont.core-font-name('Helvetica,Bold'), 'helvetica-bold', 'core-font-name';
is PDF::Content::Font::CoreFont.core-font-name('Helvetica-BoldOblique'), 'helvetica-boldoblique', 'core-font-name';
is PDF::Content::Font::CoreFont.core-font-name('Arial,Bold'), 'helvetica-bold', 'core-font-name';
is-deeply PDF::Content::Font::CoreFont.core-font-name('Blah'), Nil, 'core-font-name';

my PDF::Content::Font::CoreFont $tr-bold .= load-font( :family<Times-Roman>, :weight<bold>);
is $tr-bold.font-name, 'Times-Bold', 'font-name';

my PDF::Content::Font::CoreFont $tsym .= load-font( :family<Symbol>, :weight<bold>);
is $tsym.font-name, 'Symbol', 'font-name';
is $tsym.enc, 'sym', 'enc';

my PDF::Content::Font::CoreFont $hb-afm .= load-font( 'Helvetica-Bold' );
isa-ok $hb-afm.metrics, 'Font::AFM'; 
is $hb-afm.font-name, 'Helvetica-Bold', 'font-name';
is $hb-afm.enc, 'win', '.enc';
is $hb-afm.height, 1190, 'font height';
is $hb-afm.height(:hanging), 925, 'font height hanging';
is-approx $hb-afm.height(12), 14.28, 'font height @ 12pt';
is-approx $hb-afm.height(12, :from-baseline), 11.544, 'font base-height @ 12pt';
is-approx $hb-afm.height(12, :hanging), 11.1, 'font hanging height @ 12pt';
is $hb-afm.encode("A♥♣✔B", :str), "A\x[1]\x[2]B", '.encode(...) sanity';

my PDF::Content::Font::CoreFont $ab-afm .= load-font( 'Arial-Bold' );
isa-ok $hb-afm.metrics, 'Font::AFM'; 
is $hb-afm.font-name, 'Helvetica-Bold', 'font-name';
is $hb-afm.encode("A♥♣✔B", :str), "A\x[1]\x[2]B", '.encode(...) sanity';

my PDF::Content::Font::CoreFont $hbi-afm .= load-font( :family<Helvetica>, :weight<Bold>, :style<Italic> );
is $hbi-afm.font-name, 'Helvetica-BoldOblique', ':font-family => font-name';

my PDF::Content::Font::CoreFont $hb-afm-again .= load-font( 'Helvetica-Bold' );
ok $hb-afm-again === $hb-afm, 'font caching';

my $ext-chars = "ΨΩαΩ";
my $enc = $hbi-afm.encode($ext-chars, :str);
is $enc, "\x[1]\x[2]\x[3]\x[2]", "extended chars encoding";
is $hbi-afm.decode($enc, :str), $ext-chars,  "extended chars decoding";

$hbi-afm.cb-finish;
my $hbi-afm-dict = $hbi-afm.to-dict;
is-json-equiv $hbi-afm-dict, {
    :Type<Font>,
    :Subtype<Type1>,
    :BaseFont<Helvetica-BoldOblique>,
    :Encoding{
        :Type<Encoding>,
        :BaseEncoding<WinAnsiEncoding>,
        :Differences[1, "Psi", "Omega", "alpha"],
    },
}, "to-dict (extended chars)";

my PDF::Content::Font::CoreFont $tr-afm .= load-font( 'Times-Roman' );
is $tr-afm.stringwidth("RVX", :!kern), 2111, 'stringwidth :!kern';
is $tr-afm.stringwidth("RVX", :kern), 2111 - 80, 'stringwidth :kern';
is-deeply $tr-afm.kern("RVX" ), (['R', -80, 'VX'], 2031), '.kern(...)';

for (win => "Á®ÆØ",
     mac => "ç¨®¯") {
    my ($enc, $encoded) = .kv;
    my $fnt = PDF::Content::Font::CoreFont.load-font( 'helvetica', :$enc );
    my $decoded = "Á®ÆØ";
    my $re-encoded = $fnt.encode($decoded, :str);
    is $re-encoded, $encoded, "$enc encoding";
    is $fnt.decode($encoded, :str), $decoded, "$enc decoding";
    is-deeply $fnt.decode($encoded, ), buf16.new($decoded.ords), "$enc raw decoding";
}

my PDF::Content::Font::CoreFont $zapf .= load-font( 'ZapfDingbats' );
isa-ok $zapf.metrics, 'Font::Metrics::zapfdingbats';
is $zapf.enc, 'zapf', '.enc';
is $zapf.encode("♥♣✔", :str), "ª¨4", '.encode(...)'; # /a110 /a112 /a20
is $zapf.decode("ª¨4", :str), "♥♣✔", '.decode(...)';
is $zapf.decode("\o251\o252", :str), "♦♥", '.decode(...)';

isa-ok PDF::Content::Font::CoreFont.load-font('CourierNew,Bold').metrics, 'Font::Metrics::courier-bold';

my PDF::Content::Font::CoreFont $sym .= load-font( 'Symbol' );
isa-ok $sym.metrics, 'Font::Metrics::symbol';
is $sym.enc, 'sym', '.enc';
is $sym.encode("ΑΒΓ", :str), "ABG", '.encode(...)'; # /Alpha /Beta /Gamma
is $sym.decode("ABG", :str), "ΑΒΓ", '.decode(...)';

use Font::AFM;
use PDF::Content::Font::Enc::Type1;
my $metrics = Font::AFM.core-font('times-roman');
my @differences = [1, 'x', 'y', 10, 'a', 'b'];
my PDF::Content::Font::Enc::Type1 $encoder .= new: :enc<win>;
$encoder.differences = @differences;
my PDF::Content::Font::CoreFont $tr .= new: :$metrics, :$encoder;
is-deeply $tr.encode('abcxyz'), buf8.new(10,11,99,1,2,122), 'differences encoding';
$tr.cb-finish;
is-json-equiv $tr.to-dict<Encoding><Differences>, [1, "x", "y", 10, "a", "b"], 'dfferences to-dict';

done-testing;
