use lib "lib";

use ProblemSolver;
my ProblemSolver $problem .= new;#: :stop-on-first-solution;

my @vars = (^9 X~ ^9).map: "var" ~ *;

my %page;
for ^9 -> $i {
	my @cols = get().comb(/<[-\w]>/);
	for ^@cols -> $j {
		%page{"var$i$j"} = @cols[$j] unless @cols[$j] eq "-"
	}
}

for @vars -> $var {
	$problem.add-variable: $var, %page{$var} || 1 .. 9
}

sub print-sheet(%vals) {
	my $c;
	for @vars -> $var {
		$c++;
		if %vals{$var}:exists {
			print %vals{$var}, "  ";
		} else {
			print "-  "
		}
		print "  " if $c %% 3;
		print "\n" if $c %% 9;
		print "\n" if $c %% 27;
	}
}

$problem.print-found = -> %values {
	print "\e[0;0H\e[0J";
	print-sheet(%values);
}

for ^9 -> $i {
	$problem.unique-vars: (^9).map("var$i" ~ *)
}

for ^9 -> $j {
	$problem.unique-vars: (^9).map("var" ~ * ~ $j)
}

for ^3 X ^3 -> ($i, $j) {
	$problem.unique-vars: (
		(3 * $i,		3 * $j),	(3 * $i, 		3 * $j + 1),	(3 * $i,		3 * $j + 2),
		(3 * $i + 1,	3 * $j),	(3 * $i + 1,	3 * $j + 1),	(3 * $i + 1,	3 * $j + 2),
		(3 * $i + 2,	3 * $j),	(3 * $i + 2,	3 * $j + 1),	(3 * $i + 2,	3 * $j + 2),
	).map(-> ($I, $J) {"var{$I}{$J}"})
}

my @resp = $problem.solve;
say "=" x 30, " ANSWER ", "=" x 30;
print-sheet $_ for @resp
