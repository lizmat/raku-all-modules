use v6;
use Test;
plan 13;

use HTML::Canvas;
my HTML::Canvas $canvas .= new;

$canvas.context: -> \ctx {
    ctx.save; {
        is-deeply [ctx.transformMatrix], [1, 0, 0, 1, 0, 0], 'canvas transform - initial';
        ctx.strokeRect(1, 1, 610, 790);

        lives-ok { ctx.strokeRect(20,20, 10,20); }, "basic API call - lives";
        ctx.scale( 2.0, 2.0);
        is-deeply [ctx.transformMatrix], [2.0, 0.0, 0.0, 2.0, 0, 0], 'canvas transform - scaled';
        ctx.translate(-5, -15);

        is-deeply [ctx.transformMatrix], [2.0, 0.0, 0.0, 2.0, -10.0, -30.0], 'canvas transform - scaled';

        lives-ok { ctx.strokeRect(20,20, 10,20); }, "basic API call - lives";
        dies-ok  { ctx.strokeRect(10,10, 20, "blah"); }, "incorrect API call - dies";
        dies-ok  { ctx.strokeRect(10,10, 20); }, "incorrect API call - dies";
        dies-ok  { ctx.foo(42) }, "unknown call - dies";

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
        ctx.lineDash = [.8,1];
	is-deeply ctx.lineDash, Array[Numeric].new(.8, 1), 'lineDash';
        ctx.strokeRect(45,20, 4,25);
    }; ctx.restore;

    is ctx.font,  "10pt times-roman", 'restored font';
    is-deeply [ctx.transformMatrix], [1, 0, 0, 1, 0, 0], 'restored transformMatrix';

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

    with ctx.createRadialGradient(75,50,5,90,60,100) -> $grd {
        $grd.addColorStop(0,"red");
        $grd.addColorStop(0.5,"white");
        $grd.addColorStop(1,"blue");
        ctx.fillStyle = $grd;
        ctx.translate(10,200);
        ctx.fillRect(10, 10, 150, 100);
    }
}

my $html = "<html><body>{ $canvas.to-html( :width(612), :height(792) ) }</body></html>";
"t/transforms.html".IO.spurt: $html;

done-testing;
