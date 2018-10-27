use v6;
use Test;
plan 1;
use lib '.';
use PDF::Content::Ops :OpCode;
use t::PDFTiny;
# ensure consistant document ID generation
srand(123456);

my t::PDFTiny $pdf .= new;
my $page = $pdf.add-page;
my $gfx = $page.gfx;
my $width = 50;
my $font-size = 18;

my $font = $page.core-font( :family<Helvetica> );

$width = 100;
my $height = 80;
my $x = 110;

$gfx.BeginText;
$gfx.set-font( $font, 10);

my $sample = q:to"--ENOUGH!!--";
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt
ut labore et dolore magna aliqua.
--ENOUGH!!--

my $baseline = 'top';

for <top center bottom> -> $valign {

    my $y = 700;

    for <left center right justify> -> $align {
        $gfx.text-position = ($x, $y);
        $gfx.say( "*** $valign $align*** " ~ $sample, :$width, :$height, :$valign, :$align, :$baseline );
        $y -= 170;
    }

   $x += 125;
}
$gfx.EndText;

lives-ok {$pdf.save-as('t/pdf-text-align.pdf')};

done-testing;
