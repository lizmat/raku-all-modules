use v6;
use Test;
plan 17;
use PDF::Grammar::Test :is-json-equiv;
use PDF::Font;

my $vera = PDF::Font.load-font('t/fonts/Vera.ttf', :enc<win>);
is $vera.font-name, 'BitstreamVeraSans-Roman', 'font-name';

is $vera.height.round, 1164, 'font height';
is $vera.height(:from-baseline).round, 928, 'font height from baseline';
is $vera.height(:hanging).round, 1164, 'font height hanging';
is-approx $vera.height(12), 13.96875, 'font height @ 12pt';
is-approx $vera.height(12, :from-baseline), 11.138672, 'font base-height @ 12pt';
# Vera defines: AB˚. Doesn't include: ♥♣✔
is $vera.encode("A♥♣✔˚B", :str), "A\x[1]B", '.encode(...) sanity';

my $vera-dict = $vera.to-dict;
my $descriptor-dict = $vera-dict<FontDescriptor>:delete;
is-json-equiv $vera-dict, {
    :Type<Font>, :Subtype<TrueType>,
    :BaseFont<BitstreamVeraSans-Roman>,
    :Encoding<WinAnsiEncoding>,
}, "to-dict";

is $vera.stringwidth("RVX", :!kern), 2064, 'stringwidth :!kern';
is $vera.stringwidth("RVX", :kern), 2064 - 55, 'stringwidth :kern';
is-deeply $vera.kern("RVX" ), (['R', -55, 'VX'], 2064 - 55), '.kern(...)';

for (win => "Á®ÆØ",
     mac => "ç¨®¯",
     identity-h => "\0É\0\x[8a]\0\x[90]\0\x[91]") {
    my ($enc, $encoded) = .kv;
    my $fnt = PDF::Font.load-font( 't/fonts/Vera.ttf', :$enc );
    my $decoded = "Á®ÆØ";
    my $re-encoded = $fnt.encode($decoded, :str);
    is $re-encoded, $encoded, "$enc encoding";
    is $fnt.decode($encoded, :str), $decoded, "$enc decoding";
}

my $deja = PDF::Font.load-font("t/fonts/DejaVuSans.ttf");

done-testing;
