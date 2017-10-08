use v6;
use Test;
plan 40;
use PDF::Grammar::Test :is-json-equiv;
use PDF::Content::Font;
use PDF::Content::Util::Font;

is PDF::Content::Util::Font::core-font-name('Helvetica,Bold'), 'helvetica-bold', 'core-font-name';
is PDF::Content::Util::Font::core-font-name('Helvetica-BoldOblique'), 'helvetica-boldoblique', 'core-font-name';
is PDF::Content::Util::Font::core-font-name('Arial,Bold'), 'helvetica-bold', 'core-font-name';
is-deeply PDF::Content::Util::Font::core-font-name('Blah'), Nil, 'core-font-name';

my $tr-bold = PDF::Content::Util::Font::core-font( :family<Times-Roman>, :weight<bold>);
is $tr-bold.FontName, 'Times-Bold', 'FontName';

my $tsym = PDF::Content::Util::Font::core-font( :family<Symbol>, :weight<bold>);
is $tsym.FontName, 'Symbol', 'FontName';
is $tsym.enc, 'sym', 'enc';

my $hb-afm = PDF::Content::Util::Font::core-font( 'Helvetica-Bold' );
isa-ok $hb-afm, 'Font::AFM'; 
is $hb-afm.FontName, 'Helvetica-Bold', 'FontName';
is $hb-afm.enc, 'win', '.enc';
is $hb-afm.height, 1190, 'font height';
is-approx $hb-afm.height(12), 14.28, 'font height @ 12pt';
is-approx $hb-afm.height(12, :from-baseline), 11.544, 'font base-height @ 12pt';
is $hb-afm.encode("A♥♣✔B", :str), "AB", '.encode(...) sanity';

my $ab-afm = PDF::Content::Util::Font::core-font( 'Arial-Bold' );
isa-ok $hb-afm, 'Font::AFM'; 
is $hb-afm.FontName, 'Helvetica-Bold', 'FontName';
is $hb-afm.encode("A♥♣✔B", :str), "AB", '.encode(...) sanity';

my $hbi-afm = PDF::Content::Util::Font::core-font( :family<Helvetica>, :weight<Bold>, :style<Italic> );
is $hbi-afm.FontName, 'Helvetica-BoldOblique', ':font-family => FontName';

my $hb-afm-again = PDF::Content::Util::Font::core-font( 'Helvetica-Bold' );
ok $hb-afm-again === $hb-afm, 'font caching';

my $hbi-afm-dict = $hbi-afm.to-dict;
is-json-equiv $hbi-afm-dict, { :BaseFont<Helvetica-BoldOblique>, :Encoding<WinAnsiEncoding>, :Subtype<Type1>, :Type<Font>}, "to-dict";

my $tr-afm = PDF::Content::Util::Font::core-font( 'Times-Roman' );
is $tr-afm.stringwidth("RVX", :!kern), 2111, 'stringwidth :!kern';
is $tr-afm.stringwidth("RVX", :kern), 2111 - 80, 'stringwidth :kern';
is-deeply $tr-afm.kern("RVX" ), (['R', -80, 'VX'], 2031), '.kern(...)';
is-deeply $tr-afm.kern("RVX", 12), (['R', -0.96, 'VX'], 2031 * 12 / 1000), '.kern(..., $w))';

for (win => "Á®ÆØ",
     mac => "ç¨®¯") {
    my ($enc, $encoded) = .kv;
    my $fnt = PDF::Content::Util::Font::core-font( 'helvetica', :$enc );
    my $decoded = "Á®ÆØ";
    my $re-encoded = $fnt.encode($decoded, :str);
    is $re-encoded, $encoded, "$enc encoding";
    is $fnt.decode($encoded, :str), $decoded, "$enc decoding";
    is-deeply $fnt.decode($encoded, ), buf16.new($decoded.ords), "$enc raw decoding";
}

my $zapf = PDF::Content::Util::Font::core-font( 'ZapfDingbats' );
isa-ok $zapf, 'Font::Metrics::zapfdingbats';
is $zapf.enc, 'zapf', '.enc';
is $zapf.encode("♥♣✔", :str), "ª¨4", '.encode(...)'; # /a110 /a112 /a20
is $zapf.decode("ª¨4", :str), "♥♣✔", '.decode(...)';
is $zapf.decode("\o251\o252", :str), "♦♥", '.decode(...)';

isa-ok PDF::Content::Util::Font::core-font('CourierNew,Bold'), 'Font::Metrics::courier-bold';

my $sym = PDF::Content::Util::Font::core-font( 'Symbol' );
isa-ok $sym, 'Font::Metrics::symbol';
is $sym.enc, 'sym', '.enc';
is $sym.encode("ΑΒΓ", :str), "ABG", '.encode(...)'; # /Alpha /Beta /Gamma
is $sym.decode("ABG", :str), "ΑΒΓ", '.decode(...)';

done-testing;
