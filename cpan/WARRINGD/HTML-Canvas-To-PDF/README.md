# HTML-Canvas-To-PDF-p6

[![Build Status](https://travis-ci.org/p6-pdf/HTML-Canvas-To-PDF-p6.svg?branch=master)](https://travis-ci.org/p6-pdf/HTML-Canvas-To-PDF-p6)

This is a PDF rendering back-end for HTML::Canvas.

- A canvas may be rendered to either a page, or an XObject form, using
a PDF::Content graphics object
- This back-end is compatible with PDF::Lite, PDF::Class and PDF::API6.
- Supported canvas image formats are PNG, GIF, JPEG and PDF

This back-end is **experimental**.

It may be useful, if you wish to manipulate existing PDF files
use the HTML Canvas API.

```
use v6;
# Finish an existing PDF. Add a background color and page numbers

use PDF::Lite;
use PDF::Content;
use HTML::Canvas;
use HTML::Canvas::To::PDF;

# render to a PDF page
my PDF::Lite $pdf .= open: "examples/render-pdf-test-sheets.pdf";

# use a cache for shared resources such as fonts and images.
# for faster production and smaller multi-page PDF files
my HTML::Canvas::To::PDF::Cache $cache .= new;
my $pages = $pdf.page-count;

for 1 .. $pages -> $page-num {
    my $page = $pdf.page($page-num);
    my HTML::Canvas $canvas .= new;
    my PDF::Content $gfx = $page.pre-gfx;
    my HTML::Canvas::To::PDF $feed .= new: :$gfx, :$canvas, :$cache;
    $canvas.context: -> \ctx {
        ctx.fillStyle = "rgba(0, 0, 200, 0.2)";
        ctx.fillRect(10, 25, $page.width - 20, $page.height - 45);
        ctx.font = "12px Arial";
        ctx.fillStyle = "rgba(50, 50, 200, 0.8)";
        ctx.fillText("Page $page-num/$pages", 550, 15);
    }
}

$pdf.save-as: "examples/demo.pdf";
```

## Images