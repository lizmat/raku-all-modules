use v6;
use Test;
plan 1;
use lib '.';
use PDF::Grammar::Test :is-json-equiv;
use PDF::Content::Text::Block;
use PDF::Content::Font::CoreFont;
use PDF::Content::Image;
use t::PDFTiny;

# experimental feature to flow text and images

# ensure consistant document ID generation
srand(123456);

my $pdf = t::PDFTiny.new;
my $page = $pdf.add-page;

my @chunks = PDF::Content::Text::Block.comb: 'I must go down to the seas';
@chunks.append: ' ', 'aga','in';
my $font = PDF::Content::Font::CoreFont.load-font( :family<helvetica>, :weight<bold> );
my $font-size = 16;
my $image = PDF::Content::Image.open: "t/images/lightbulb.gif";

my $image-padded = $page.xobject-form(:BBox[0, 0, $image.width + 1, $image.height + 4]);
$image-padded.gfx;
$image-padded.graphics: {
    .do($image,1,0);
}

my $text-block;

$page.text: -> $gfx {
    $gfx.TextMove(100, 500);
    $text-block = $gfx.text-block( :@chunks, :$font, :$font-size, :width(220) );
    $gfx.say($text-block);
    for @chunks.grep('the'|'aga') -> $source is rw {
        $source = $image-padded;
    }
    $text-block = $gfx.text-block( :@chunks, :$font, :$font-size, :width(220) );
    $gfx.say($text-block);

    is-json-equiv [$text-block.images.map({[ .<Tx>, .<Ty> ]})], [
        [141.344, 0],
        [0.0, -25.3]
    ], 'images';
}

$text-block.place-images($page.gfx);

$page.graphics: -> $gfx {
    $gfx.HorizScaling = 120;
    my $text = q:to<END-QUOTE>;
    To be, or not to be, that is the question:
    Whether 'tis nobler in the mind to suffer
    The slings and arrows of outrageous fortune,
    Or to take Arms against a Sea of troubles,
    And by opposing end them: to die, to sleep
    No more; and by a sleep, to say we end
    the heart-ache, and the thousand natural shocks
    that Flesh is heir to? 'Tis a consummation
    devoutly to be wished.
    END-QUOTE

    my @chunks = PDF::Content::Text::Block.comb($text);
    for @chunks.grep('the') -> $source is rw {
        my $width = $font.stringwidth($source, $font-size);
        my $height = $font-size * 1.5;
        $source = $image-padded;
    }
    $text-block = $gfx.text-block( :@chunks, :$font, :$font-size, :width(250) );
    $page.text: {
        $gfx.print($text-block, :position[100, 400]);
    }
}

$text-block.place-images($page.gfx);

$pdf.save-as: "t/text-block-images.pdf";
