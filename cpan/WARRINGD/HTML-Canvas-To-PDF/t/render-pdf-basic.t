use v6;
use Test;
plan 20;

use PDF::Lite;
use HTML::Canvas;
use HTML::Canvas::To::PDF;

my HTML::Canvas $canvas .= new;
my PDF::Lite $pdf .= new;
my PDF::Content $gfx = $pdf.add-page.gfx;
my HTML::Canvas::To::PDF $feed .= new: :$gfx, :$canvas;
is $feed.width, 612, 'renderer default width';
is $feed.height, 792, 'rendered default height';

$canvas.context: -> \ctx {
    ctx.save; {
        is-deeply [ctx.transformMatrix], [1, 0, 0, 1, 0, 0], 'canvas transform - initial';
        is-deeply [$gfx.CTM.list], [1, 0, 0, 1, 0, 792], 'pdf transform - initial';
        ctx.strokeRect(1, 1, 610, 790);

        lives-ok { ctx.strokeRect(20,20, 10,20); }, "basic API call - lives";
        ctx.scale( 2.0, 2.0);
        is-deeply [ctx.transformMatrix], [2.0, 0.0, 0.0, 2.0, 0, 0], 'canvas transform - scaled';
        is-deeply [$gfx.CTM.list], [2, 0, 0, 2, 0, 792], 'pdf transform - scaled';
        ctx.translate(-5, -15);

        is-deeply [ctx.transformMatrix], [2.0, 0.0, 0.0, 2.0, -10.0, -30.0], 'canvas transform - scaled';
        is-deeply [$gfx.CTM.list], [2, 0, 0, 2, -5*2, 792  +  15*2], 'pdf transform - scaled + translated';

        lives-ok { ctx.strokeRect(20,20, 10,20); }, "basic API call - lives";
        dies-ok  { ctx.strokeRect(10,10, 20, "blah"); }, "incorrect API call - dies";
        dies-ok  { ctx.strokeRect(10,10, 20); }, "incorrect API call - dies";
        dies-ok  { ctx.foo(42) }, "unknown call - dies";

        is-deeply $feed.content-dump.grep(* !~~ /^'%'/), $(
	    "q", "0 0 612 792 re", "h", "W", "n", "1 0 0 1 0 792 cm", "2 j", "q",
	    "0 0 0 RG", "1 -791 610 790 re", "s", "20 -40 10 20 re", "s",
	    "2 0 0 2 0 0 cm", "1 0 0 1 -5 15 cm", "20 -40 10 20 re", "s"), 'content to-date';

        lives-ok { ctx.font = "24px Arial"; }, 'set font - lives';
        is ctx.font,  "24px Arial", 'font';
        ctx.fillText("Hello World",50, 40);
        ctx.strokeRect(40,20, 10,25);
        ctx.rotate(.2);
        ctx.font = "18pt Arial";
        ctx.fillText("Hello World",50, 40);
        ctx.strokeStyle = 'red';
        ctx.strokeRect(40,20, 4,25);
        ctx.strokeStyle = 'blue';
        ctx.setLineDash([.8,1]);
        ctx.strokeRect(45,20, 4,25);
    }; ctx.restore;

    is ctx.font,  "10pt times-roman", 'restored font';
    is-deeply [ctx.transformMatrix], [1, 0, 0, 1, 0, 0], 'restored transformMatrix';
    is-deeply [$gfx.CTM.list], [1, 0, 0, 1, 0, 792], 'restored $gfx.CTM';
    
    ctx.save; {
        ctx.translate(200,0);
        ctx.fillStyle = "#aaa";
        ctx.beginPath();
        ctx.arc(100, 100, 75, 0, 2 * pi);
        ctx.fill();
        ctx.fillStyle = "rgba(255, 165, 0, .65)";
        ctx.fillRect(20, 20, 50, 50);
        ctx.font = "24px Helvetica";
        ctx.fillStyle = "#000";
        ctx.fillText("Canvas", 50, 130);
    }; ctx.restore;
}

lives-ok {$pdf.save-as("t/render-pdf-basic.pdf")}, "pdf.save-as";

# also save comparative HTML

my $width = $feed.width;
my $height = $feed.height;
my $html = "<html><body>{ $canvas.to-html( :$width, :$height ) }</body></html>";
"t/render-pdf-basic.html".IO.spurt: $html;

done-testing;
