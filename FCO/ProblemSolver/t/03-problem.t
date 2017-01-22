use lib "lib";
use Test;

use-ok "ProblemSolver";
use ProblemSolver;

my $p = ProblemSolver.new;

ok $p;
$p.add-variable: "A", ^10;
$p.add-variable: "B", ^10;

is $p.solve.sort, (do for ^10 X ^10 -> ($A, $B) {
	{:$A, :$B},
}).sort;

$p.add-constraint: -> :$A!, :$B! { $A + $B == 10 }

is $p.solve.sort, (
	{:A(1), :B(9)},
	{:A(2), :B(8)},
	{:A(3), :B(7)},
	{:A(4), :B(6)},
	{:A(5), :B(5)},
	{:A(6), :B(4)},
	{:A(7), :B(3)},
	{:A(8), :B(2)},
	{:A(9), :B(1)},
).sort;

$p.unique-vars: <A B>;

is $p.solve.sort, (
	{:A(1), :B(9)},
	{:A(2), :B(8)},
	{:A(3), :B(7)},
	{:A(4), :B(6)},

	{:A(6), :B(4)},
	{:A(7), :B(3)},
	{:A(8), :B(2)},
	{:A(9), :B(1)},
).sort;

done-testing;
