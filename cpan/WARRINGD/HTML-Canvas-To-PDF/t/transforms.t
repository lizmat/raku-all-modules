use v6;
use Test;
plan 2;

use HTML::Canvas::Image;
use HTML::Canvas;
use HTML::Canvas::To::PDF;
use PDF::Lite;
my PDF::Lite $pdf .= new;
my $page-no;
my @html-body;
my @sheets;

my $y = 0;
my \h = 20;
my \pad = 10;
my \textHeight = 20;
my $measured-text;

sub test-page(&markup) {
    my HTML::Canvas $canvas .= new;
    my $gfx = $pdf.add-page.gfx;
    my $feed = HTML::Canvas::To::PDF.new: :$gfx, :$canvas;
    my Bool $clean = True;
    $page-no++;
        $canvas.context(
            -> \ctx {
                $y = 0;
                ctx.font = "20pt times";
                &markup(ctx, $gfx);
            });

    try {
        CATCH {
            default {
                warn "stopped on page $page-no: {.message}";
                $clean = False;
                # flush
                $canvas.beginPath if $canvas.subpath;
                $canvas.restore while $canvas.gsave;
                $canvas._finish;
            }
        }
    }

    ok $clean, "completion of page $page-no";
    my $width = $feed.width;
    my $height = $feed.height;
    @html-body.push: "<hr/>" ~ $canvas.to-html( :$width, :$height );
    @sheets.push: $canvas;
}

my \image = HTML::Canvas::Image.open("t/images/crosshair-100x100.jpg");

@html-body.push: HTML::Canvas.to-html: image, :style("visibility:hidden");

test-page(
    -> \ctx, \gfx {
        constant h = 100;
        my $html-transform;         

        ctx.fillText("Testing Transforms", 20, $y += textHeight);
        $y += pad + 10;
        my \pat = ctx.createPattern(image,'repeat');
        my $n;

        for (
            [:translate(50,50), :scale(2,2)],
            [:scale(2,2), :translate(100, 30) ],
            [:translate(75,300), :scale(2,2), :rotate(pi/16) ],
            [:rotate(1), :scale(2,3), :translate(-15, 32), :setTransform(2, 0, .3, 2, 200, 300) ],
            [:translate(75,300), :scale(1.5,2.5), :rotate(pi/16) ],
          ) -> \t {
          ctx.save(); {
              ctx."{.key}"(|.value) for t.list;
              $html-transform = ctx.transformMatrix.list;
              ctx.font = "italic 5pt courier";
              ctx.fillText("h#{++$n}:"~[$html-transform.map: *.fmt('%.2f')].perl, 0, 0);
              ctx.strokeStyle = 'red';
              ctx.fillStyle = pat;
              ctx.fillRect(0,10,75,100);
              ctx.strokeRect(0,10,75,100);
          }; ctx.restore();

          $y += h + pad;
      }
});

lives-ok {$pdf.save-as("t/transforms.pdf")}, "pdf.save-as";

my $html = "<html><body>" ~ @html-body.join ~ "</body></html>";

"t/transforms.html".IO.spurt: $html;

done-testing;
