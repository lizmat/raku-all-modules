use v6;
use Test;
plan 6;
use lib '.';
use PDF::Grammar::Test :is-json-equiv;
use PDF::Content::Text::Block;
use PDF::Content::Font::CoreFont;
use PDF::Content::Color :color, :ColorName;
use t::PDFTiny;

# ensure consistant document ID generation
srand(123456);

my \nbsp = "\c[NO-BREAK SPACE]";
my @chunks =  PDF::Content::Text::Block.comb: "z80 a-b. -3   {nbsp}A{nbsp}bc{nbsp} 42";
is-deeply @chunks, ["z80", " ", "a-", "b.", " ", "-", "3", "   ", "{nbsp}A{nbsp}bc{nbsp}", " ", "42"], 'text-block comb';

my $font = PDF::Content::Font::CoreFont.load-font( :family<helvetica>, :weight<bold> );
my $font-size = 16;
my $text = "Hello.  Ting, ting-ting. Attention! … ATTENTION! ";
my $pdf = t::PDFTiny.new;
my $text-block = PDF::Content::Text::Block.new( :$text, :$font, :$font-size );
is-approx $text-block.content-width, 360.88, '$.content-width';
is-approx $text-block.content-height, 17.6, '$.content-height';
my $gfx = $pdf.add-page.gfx;
$gfx.Save;
$gfx.BeginText;
$gfx.text-position = [100, 350];
$gfx.FillColor = color Blue;
is-deeply $gfx.text-position, (100.0, 350.0), 'text position';
$gfx.say( $text-block );
is-deeply $gfx.text-position, (100.0, 350 - 17.6), 'text position';
$text-block.TextRise = $text-block.baseline-shift('bottom');
$gfx.print( $text-block, :!preserve );
$gfx.EndText;
$gfx.Restore;

is-json-equiv [ $gfx.ops ], [
    :q[],
    :BT[],
    :Tm[ :real(1),   :real(0),
         :real(0),   :real(1),
         :real(100), :real(350), ],
    :rg[ :real(0), :real(0), :real(1) ],
    :Tf[:name<F1>,   :real(16)],
    :Tj[ :literal("Hello. Ting, ting-ting. Attention! \x[85] ATTENTION!")],
    :TL[:real(17.6)],
    'T*' => [],
    :Ts[ :real(3.648) ],
    :Tj[ :literal("Hello. Ting, ting-ting. Attention! \x[85] ATTENTION!")],
    :ET[],
    :Q[],
    ], 'simple text block';

$pdf.save-as: "t/text-block.pdf";
