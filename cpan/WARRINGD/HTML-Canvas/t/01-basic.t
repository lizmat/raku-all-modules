use v6;
use Test;
plan 7;

use HTML::Canvas;

my HTML::Canvas $canvas .= new;

lives-ok { $canvas.rect(100,100, 50,20); }, "basic API call - lives";
dies-ok { $canvas.rect(100,100, 50, "blah"); }, "incorrect API call - dies";
dies-ok { $canvas.rect(100,100, 50); }, "incorrect API call - dies";
dies-ok { $canvas.foo(42) }, "unknown call - dies";
$canvas.fill;
$canvas.scale(2.0, 3.0);
$canvas.font = "30px Arial";
$canvas.fillText("Hello World",10,50);

is-deeply [$canvas.transformMatrix], [2.0, 0.0, 0.0, 3.0, 0, 0], '.TransformMatrix';
is-deeply [$canvas.calls], [ :rect[100,100,50,20], :fill[], :scale[2.0, 3.0], :font[ "30px Arial", ], :fillText['Hello World', 10,50], ], '.calls';

is-deeply $canvas.js.lines, ('ctx.rect(100, 100, 50, 20);', 'ctx.fill();', 'ctx.scale(2.0, 3.0);', 'ctx.font = "30px Arial";', 'ctx.fillText("Hello World", 10, 50);'), '.js';

done-testing;
