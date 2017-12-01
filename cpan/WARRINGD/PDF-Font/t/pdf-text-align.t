use v6;
use Test;
plan 1;
use PDF::Lite;
use PDF::Font;
# ensure consistant document ID generation
srand(123456);

my $pdf = PDF::Lite.new;
my $page = $pdf.add-page;
my $gfx = $page.gfx;
my $width = 100;
my $height = 80;
my $x = 110;

my $font = PDF::Font.load-font: :name<t/fonts/DejaVuSans.ttf>;

$gfx.text: -> $gfx {
    $gfx.font = $font, 10;

    my $sample = q:to"--ENOUGH!!--";
        Lorem ipsum dolor sit amet, consectetur adipiscing elit,  sed
        do eiusmod tempor incididunt ut labore et dolore magna aliqua.
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
}

lives-ok {$pdf.save-as('t/pdf-text-align.pdf')};

done-testing;
