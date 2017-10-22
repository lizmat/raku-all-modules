unit module Test::Fuzz;
use Test::Fuzz::Generators;
use Test::Fuzz::Fuzzed;

my %funcs;

our sub add-func(Routine $f) {
	%funcs.push: $f.name => $f
}

#| trait is fuzzed can receive params :returns and :test
multi trait_mod:<is> (Routine $func,
		:$fuzzed! where Map|List (:$returns, :&test)
) is export {
	$func does Test::Fuzz::Fuzzed[:$returns, :&test];
	$func.compose;
	add-func $func
}

#| trait is fuzzed
multi trait_mod:<is> (Routine $func, Bool :$fuzzed!) is export {
	$func does Test::Fuzz::Fuzzed;
	$func.compose;
	add-func $func
}

#| function that run fuzzed tests
sub run-tests(
	@funcs = %funcs.keys.sort, #= if no specified the functions, it runs all fuzzed tests
	Int :$runs #The number of tests to run.
	--> Nil
) is export {
		(%funcs{@funcs}:v)».run-tests: |($_ with $runs)
}
