use Test;
use lib "lib";

use-ok "Heap";

use Heap;

my $h1 = Heap.new(<1 2 3>);
my $h2 = Heap.new(3, 2, 1);

ok $h1.defined, "Heap defined with array";
ok $h2.defined, "Heap defined with list os pars";

ok	$h1 ~~ $h2, "Compare heaps";
my $h3 = Heap.new(2, 3);
note "h1({$h1.Array}), h3({$h3.Array})";
ok	$h1 !~~ $h3, "compare non equal heaps";

$h3.push: 1;
ok	$h1 ~~ $h3, "Compare heaps 2";

my $m1 = Heap[-*].new(<1 2 3>);
my $m2 = Heap[-*].new(3, 2, 1);
ok	$m1 ~~ $m2, "Compare heaps 3";

my $p1 = Heap.new: <1 2 3 4 a b e c e f 5 4 3 2 1 -1 -2 0>;
is	$p1.pop, -2;
is	$p1.pop, -1;
is	$p1.pop, 0;
is	$p1.pop, 1;
is	$p1.pop, 1;
is	$p1.pop, 2;
is	$p1.pop, 2;
is	$p1.pop, 3;
is	$p1.pop, 3;
is	$p1.pop, 4;
is	$p1.pop, 4;
is	$p1.pop, 5;
is	$p1.pop, "a";
is	$p1.pop, "b";
is	$p1.pop, "c";
is	$p1.pop, "e";
is	$p1.pop, "e";
is	$p1.pop, "f";
is	$p1.pop, Any;

my $p2 = Heap[*<aaa>].new:
	{:aaa<9>},
	{:aaa<8>},
	{:aaa<7>},
	{:aaa<6>},
	{:aaa<5>},
	{:aaa<4>},
	{:aaa<3>},
	{:aaa<2>},
	{:aaa<1>},
	{:aaa<0>},
;

is	$p2.pop<aaa>, 0;
is	$p2.pop<aaa>, 1;
is	$p2.pop<aaa>, 2;
is	$p2.pop<aaa>, 3;
is	$p2.pop<aaa>, 4;
is	$p2.pop<aaa>, 5;
is	$p2.pop<aaa>, 6;
is	$p2.pop<aaa>, 7;
is	$p2.pop<aaa>, 8;
is	$p2.pop<aaa>, 9;
is	$p2.pop<aaa>, Any;

my $p3 = Heap[-*<aaa>].new:
	{:aaa<9>},
	{:aaa<8>},
	{:aaa<7>},
	{:aaa<6>},
	{:aaa<5>},
	{:aaa<4>},
	{:aaa<3>},
	{:aaa<2>},
	{:aaa<1>},
	{:aaa<0>},
;

is	$p3.pop<aaa>, 9;
is	$p3.pop<aaa>, 8;
is	$p3.pop<aaa>, 7;
is	$p3.pop<aaa>, 6;
is	$p3.pop<aaa>, 5;
is	$p3.pop<aaa>, 4;
is	$p3.pop<aaa>, 3;
is	$p3.pop<aaa>, 2;
is	$p3.pop<aaa>, 1;
is	$p3.pop<aaa>, 0;
is	$p3.pop<aaa>, Any;

my $p4 = Heap[*].new: ^10;
is $p4.all, <0 1 2 3 4 5 6 7 8 9>;

my $p5 = Heap[-*].new: ^10;
is $p5.all, <9 8 7 6 5 4 3 2 1 0>;

done-testing;
