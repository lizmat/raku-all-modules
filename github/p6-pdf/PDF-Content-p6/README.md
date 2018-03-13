# PDF::Content

This Perl 6 module is a library of roles and classes for basic PDF content creation and rendering, including text, images, fonts and general graphics.

It is centered around implementing a graphics state machine and provding support for the operators and graphics variables
as listed in the [PDF::API6 Graphics Documentation](https://github.com/p6-pdf/PDF-API6#appendix-i-graphics).

## Key roles and classes:

### `PDF::Content`
implements a PDF graphics state machine for composition, or rendering:
```
use PDF::Content;
my PDF::Content $gfx .= new;
$gfx.BeginText;
$gfx.Font = 'F1', 16;
$gfx.TextMove(10, 20);
$gfx.ShowText('Hello World');
$gfx.EndText;
say $gfx.Str;
# BT
#  /F1 16 Tf
#  10 20 Td
#  (Hello World) Tj
# ET
```

### `PDF::Content::Image`
handles the loading of some common image formats

It currently supports: PNG, GIF and JPEG.

```
use PDF::Content::Image;
use PDF::Content::XObject;
my PDF::Content::XObject $image = PDF::Content::Image.open: "t/images/lightbulb.gif";
say "image has size {$image.width} X {$image.height}";
say $image.data-uri;
# data:image/gif;base64,R0lGODlhEwATAMQA...
```

### `PDF::Content::Font::CoreFont`
provides simple support for core fonts

```
use PDF::Content::Font::CoreFont;
my $font = PDF::Content::Font::CoreFont.load-font( :family<Times-Roman>, :weight<bold> );
say $font.encode("¶Hi");
say $font.stringwidth("RVX"); # 2166
say $font.stringwidth("RVX", :kern); # 2111
```

### `PDF::Content::Text::Block`
a utility class for creating and outputting simple text lines and paragraphs:

```
use PDF::Content;
use PDF::Content::Font::CoreFont;
use PDF::Content::Text::Block;
my $font = PDF::Content::Font::CoreFont.load-font( :family<helvetica>, :weight<bold> );
my $font-size = 16;
my $text = "Hello.  Ting, ting-ting. Attention! … ATTENTION! ";
my $text-block = PDF::Content::Text::Block.new( :$text, :$font, :$font-size );
my PDF::Content $gfx .= new;
$gfx.BeginText;
$text-block.render($gfx);
$gfx.EndText;
say $gfx.Str;
```

### `PDF::Content::Color`

Simple Color construction functions:

    use PDF::Content;
    use PDF::Content::Color :color, :ColorName;
    PDF::Content $gfx .= new;
    $gfx.FillColor = color Blue; # named color
    $gfx.StrokeColor = color '#fa9'; # RGB mask, 3 digit
    $gfx.StrokeColor = color '#ffaa99'; # RGB mask, 6 digit
    $gfx.StrokeColor = color [1, .8, .1, .2]; # CMYK color values (0..1)
    $gfx.StrokeColor = color [1, .5, .1];     # RGB color values (0..1)
    $gfx.StrokeColor = color [255, 127, 25];  # RGB color values (0..255)
    $gfx.StrokeColor = color .7; # Shade of gray
    use Color;
    my Color $red .= new(0xff, 0x0a, 0x0a)
    $gfx.StrokeColor = color $red; # Color objects

## See Also

- [PDF::Lite](https://github.com/p6-pdf/PDF-Lite-p6) minimal creation and manipulation of PDF documents.

- [PDF::API6](https://github.com/p6-pdf/PDF-API6) PDF manipulation library.



