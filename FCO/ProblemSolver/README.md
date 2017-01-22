[![Build Status](https://travis-ci.org/FCO/ProblemSolver.svg?branch=master)](https://travis-ci.org/FCO/ProblemSolver)

# ProblemSolver

```perl6
use Problem;
my Problem $problem .= new;

$problem.add-variable: "a", ^100;
$problem.add-variable: "b", ^100;

$problem.add-constraint: -> :$a!, :$b! {$a * 3 == $b + 14};
$problem.add-constraint: -> :$a!, :$b! {$a * 2 == $b};

say $problem.solve						# ((a => 14 b => 28))
```

```perl6
# SEND + MORE = MONEY

use Problem;
my Problem $problem .= new: :stop-on-first-solution;

$problem.add-variable: "S", 1 ..^ 10;
$problem.add-variable: "E", ^10;
$problem.add-variable: "N", ^10;
$problem.add-variable: "D", ^10;
$problem.add-variable: "M", 1 ..^ 10;
$problem.add-variable: "O", ^10;
$problem.add-variable: "R", ^10;
$problem.add-variable: "Y", ^10;


$problem.constraint-vars: &infix:<!=>, <S E N D M O R Y>;
$problem.add-constraint: -> :$S!, :$E!, :$N!, :$D!, :$M!, :$O!, :$R!, :$Y! {
	note "$S$E$N$D + $M$O$R$E == $M$O$N$E$Y";

					1000*$S + 100*$E + 10*$N + $D
	+				1000*$M + 100*$O + 10*$R + $E
	==	10000*$M +	1000*$O + 100*$N + 10*$E + $Y
};


say $problem.solve
# You can wait for ever...
```

```perl6
# 4 queens

use Problem;

class Point {
	has Int $.x;
	has Int $.y;

	method WHICH {
		"{self.^name}(:x($!x), :y($!y))"
	}
	method gist {$.WHICH}
}

sub MAIN(Int $n = 4) {
	my Problem $problem .= new: :stop-on-first-solution;

	sub print-board(%values) {
		my @board;
		for %values.kv -> $key, (:x($row), :y($col)) {
			@board[$row; $col] = $key;
		}
		for ^$n -> $row {
			for ^$n -> $col {
				if @board[$row; $col]:exists {
					print "● "
				} else {
					print "◦ "
				}
			}
			print "\n"
		}
		print "\n"
	}

	$problem.print-found = -> %values {
		print "\e[0;0H\e[0J";
		print-board(%values);
	}

	my @board = (^$n X ^$n).map(-> ($x, $y) {Point.new: :$x, :$y});
	my @vars = (1 .. $n).map: {"Q$_"};

	for @vars -> $var {
		$problem.add-variable: $var, @board;
	}

	$problem.unique-vars: @vars;

	$problem.constraint-vars: -> $q1, $q2 {
			$q1.x 			!= $q2.x
		&&	$q1.y			!= $q2.y
		&&	$q1.x - $q1.y	!= $q2.x - $q2.y
		&&	$q1.x + $q1.y	!= $q2.x + $q2.y
	}, @vars;

	my @response = $problem.solve;
	say "\n", "=" x 30, " Answers ", "=" x 30, "\n";

	for @response -> %ans {
		print-board(%ans)
	}
}
```

```perl6
# colorize map

use Problem;
my Problem $problem .= new: :stop-on-first-solution;

my @colors = <green yellow blue white>;

my @states = <
	acre				alagoas
	amapa				amazonas
	bahia				ceara
	espirito-santo		goias
	maranhao			mato-grosso
	mato-grosso-do-sul	minas-gerais
	para				paraiba
	parana				pernambuco
	piaui				rio-de-janeiro
	rio-grande-do-norte	rio-grande-do-sul
	rondonia			roraima
	santa-catarina		sao-paulo
	sergipe				tocantins
>;

for @states -> $state {
	$problem.add-variable: $state, @colors;
}

$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <acre amazonas>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <amazonas roraima>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <amazonas rondonia>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <amazonas para>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <para amapa>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <para tocantins>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <para mato-grosso>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <para maranhao>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <maranhao tocantins>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <maranhao piaui>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <piaui ceara>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <piaui pernambuco>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <piaui bahia>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <ceara rio-grande-do-norte>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <ceara paraiba>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <ceara pernambuco>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <rio-grande-do-norte paraiba>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <pernambuco alagoas>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <alagoas sergipe>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <sergipe bahia>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <bahia minas-gerais>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <bahia espirito-santo>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <bahia tocantins>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <bahia goias>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <mato-grosso goias>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <mato-grosso tocantins>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <mato-grosso rondonia>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <mato-grosso mato-grosso-do-sul>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <mato-grosso-do-sul goias>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <mato-grosso-do-sul minas-gerais>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <mato-grosso-do-sul sao-paulo>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <mato-grosso-do-sul parana>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <sao-paulo minas-gerais>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <sao-paulo rio-de-janeiro>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <rio-de-janeiro espirito-santo>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <rio-de-janeiro minas-gerais>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <minas-gerais espirito-santo>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <parana santa-catarina>;
$problem.constraint-vars: -> $color1, $color2 { $color1 !eq $color2 }, <santa-catarina rio-grande-do-sul>;

my %res = $problem.solve.first;
my $size = %res.keys.map(*.chars).max;
for %res.kv -> $state, $color {
	printf "%{$size}s => %s\n", $state, $color;
}

```
