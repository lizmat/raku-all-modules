unit module Test::Fuzz;
use Test::Fuzz::Generators;
use Test::Fuzz::Fuzzed;

my Routine %funcs;

our sub add-func(Routine $f) {
	%funcs.push: $f.name => $f
}

#| trait is fuzzed can receive params :returns and :test
multi trait_mod:<is> (Routine $func, :$fuzzed! (:$returns, :&test)) is export {
	$func does Test::Fuzz::Fuzzed[:$returns, :&test];
	$func.compose;
	add-func $func
}

#| trait is fuzzed
multi trait_mod:<is> (Routine $func, :$fuzzed!) is export {
	$func does Test::Fuzz::Fuzzed;
	$func.compose;
	add-func $func
}

#| function that run fuzzed tests
sub run-tests(
	@funcs = %funcs.keys.sort, #= if no specified the functions, it runs all fuzzed tests
	Int :$runs #The number of tests to run.
) is export {
	for %funcs{@funcs}:v -> +@f {
		defined $runs
			?? @f>>.run-tests($runs)
			!! @f>>.run-tests
	}
}
