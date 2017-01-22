use lib "lib";

use ProblemSolver;
my ProblemSolver $problem .= new: :stop-on-first-solution;

$problem.add-variable: "S", 9;
$problem.add-variable: "E", ^8;
$problem.add-variable: "N", 1 ..^ 10;
$problem.add-variable: "D", ^10;
$problem.add-variable: "M", 1;
$problem.add-variable: "O", 0;
$problem.add-variable: "R", ^10;
$problem.add-variable: "Y", ^10;

$problem.unique-vars: <S E N D M O R Y>;
$problem.add-constraint: -> :$E!, :$D!, :$Y! { $D + $E = $Y | $Y + 10 };
$problem.add-constraint: -> :$E!, :$N! { $E + 1 == $N };
$problem.add-constraint: -> :$R!, :$N! { $N + $R > 9 };
$problem.add-constraint: -> :$E!, :$N!, :$R!, :$D!, :$Y! {
					10 * $N + $D
	+				10 * $R + $E
	==	(0 | 100) +	10 * $E + $Y
};
$problem.add-constraint: -> :$E!, :$N!, :$D!, :$O!, :$R!, :$Y! {

					 100*$E + 10*$N + $D
	+				 100*$O + 10*$R + $E
	==	(0 | 1000) + 100*$N + 10*$E + $Y
};
$problem.add-constraint: -> :$S!, :$E!, :$N!, :$D!, :$M!, :$O!, :$R!, :$Y! {
					1000*$S + 100*$E + 10*$N + $D
	+				1000*$M + 100*$O + 10*$R + $E
	==	10000*$M +	1000*$O + 100*$N + 10*$E + $Y
};


my %resp = $problem.solve.first;
say %resp<S E N D>.join, " + ", %resp<M O R E>.join, " == ", %resp<M O N E Y>.join
