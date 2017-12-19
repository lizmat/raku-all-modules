use v6;
use Test;
plan 1;

use HTML::Canvas;
use HTML::Canvas::Image;

my HTML::Canvas $canvas .= new;
my @html-body;

my \jpg-image = HTML::Canvas::Image.open("t/images/crosshair-100x100.jpg");
my \png-image = HTML::Canvas::Image.open("t/images/crosshair-100x100.png");
@html-body.push: HTML::Canvas.to-html: jpg-image, :style("visibility:hidden");
@html-body.push: HTML::Canvas.to-html: png-image, :style("visibility:hidden");

my $y = 10;
my \pad = 10;
my \textHeight = 20;

lives-ok {
    $canvas.context: -> \ctx {
	  ctx.fillText("Testing drawImage", 0, $y += textHeight);
	  $y += pad + 10;

	  ctx.drawImage(jpg-image,  20,  $y+0,  50, 50);
	  ctx.drawImage(png-image,  120,  $y+0,  50, 50);
    }

    @html-body.push: $canvas.to-html( :width(612), :height(792) );
};

my $html = "<html><body>" ~ @html-body.join ~ "</body></html>";
"t/images.html".IO.spurt: $html;

$canvas.image.write_png: "tmp/images.png";

done-testing;
