# -*- perl -*-

use Test;
use IRC::Art;

plan 11;

my $art = IRC::Art.new(8,1);

$art.text('Test',2,0);
is-deeply([$art.result],[("  Test  ")]);

$art.text('Test2',1,0);
is-deeply([$art.result],[(" Test2  ")]);

$art.rectangle(0,0,7,0,:clear);
$art.text('Test',2,0,:color(2));
is-deeply([$art.result],[("  \x[3]2T\x[3]\x[3]2e\x[3]\x[3]2s\x[3]\x[3]2t\x[3]  ")]);

$art.rectangle(0,0,7,0,:color(5));
$art.text('Test',2,0,:color(2));
is-deeply([$art.result],[("\x[3]5,5 \x[3]\x[3]5,5 \x[3]\x[3]2,5T\x[3]\x[3]2,5e\x[3]\x[3]2,5s\x[3]\x[3]2,5t\x[3]\x[3]5,5 \x[3]\x[3]5,5 \x[3]")]);


$art.rectangle(0,0,7,0,:clear);
$art.text('  Test  ',0,0,:color(2),:bg(5));
is-deeply([$art.result],[("\x[3]2,5 \x[3]\x[3]2,5 \x[3]\x[3]2,5T\x[3]\x[3]2,5e\x[3]\x[3]2,5s\x[3]\x[3]2,5t\x[3]\x[3]2,5 \x[3]\x[3]2,5 \x[3]")]);

$art.rectangle(0,0,7,0,:clear);
$art.text('Test',2,0, :bold);
is-deeply([$art.result],[("  \x[2]T\x[2]\x[2]e\x[2]\x[2]s\x[2]\x[2]t\x[2]  ")]);

$art.rectangle(0,0,7,0,:clear);
$art.text('Test',2,0, :bold, :color(5));
is-deeply([$art.result],[("  \x[3]5\x[2]T\x[2]\x[3]\x[3]5\x[2]e\x[2]\x[3]\x[3]5\x[2]s\x[2]\x[3]\x[3]5\x[2]t\x[2]\x[3]  ")]);

$art.rectangle(0,0,7,0, :clear);
$art.text('Test',2,0,:bold, :color(2), :bg(5));
is-deeply([$art.result],[("  \x[3]2,5\x[2]T\x[2]\x[3]\x[3]2,5\x[2]e\x[2]\x[3]\x[3]2,5\x[2]s\x[2]\x[3]\x[3]2,5\x[2]t\x[2]\x[3]  ")]);

$art.rectangle(0,0,7,0,:clear);
$art.text('1234',2,0,:color(2),:bg(5));
is-deeply([$art.result],[("  \x[3]02,051\x[3]\x[3]02,052\x[3]\x[3]02,053\x[3]\x[3]02,054\x[3]  ")]);

$art.rectangle(0,0,7,0,:clear);
$art.text('1234',2,0,:bold, :color(2), :bg(5));
is-deeply([$art.result],[("  \x[3]02,05\x[2]1\x[2]\x[3]\x[3]02,05\x[2]2\x[2]\x[3]\x[3]02,05\x[2]3\x[2]\x[3]\x[3]02,05\x[2]4\x[2]\x[3]  ")]);

$art.rectangle(0,0,7,0, :clear);
$art.text('1234',2,0, :bold, :color(2), :bg(14));
is-deeply([$art.result],[("  \x[3]02,14\x[2]1\x[2]\x[3]\x[3]02,14\x[2]2\x[2]\x[3]\x[3]02,14\x[2]3\x[2]\x[3]\x[3]02,14\x[2]4\x[2]\x[3]  ")]);






