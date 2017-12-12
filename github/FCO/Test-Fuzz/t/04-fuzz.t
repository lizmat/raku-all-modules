use Test;

use lib "lib";

use-ok "Test::Fuzz";

{
	use Test::Fuzz;

	my sub test-func(Int $a, Str :$b) is fuzzed {}

	is &test-func.fuzzed, True;
}

{
	use Test::Fuzz;

	my sub test-func(Int $a, Str :$b) is fuzzed(:42returns, :test{.so}) {}

	is &test-func.fuzzed, True, '.fuzzed';
	is-deeply &test-func.returns, 42, '.returns';
	is-deeply &test-func.test.(1), True, '.test';
}

{
	use Test::Fuzz;

	#Make sure the `fuzz` function can add existing subs.
	sub foo(Int $a) {…}
	fuzz &foo;

	is &foo.fuzzed, True, 'Fuzz existing';
}

{
	use Test::Fuzz;

	#Make sure the `fuzz` function can add existing multi subs.
	multi sub foo(Int $a) {…}
	multi sub foo(Str $a) {…}
	fuzz &foo;

	for (&foo.candidates) {
		is .fuzzed, True, 'Fuzz existing';
	}
}


done-testing
