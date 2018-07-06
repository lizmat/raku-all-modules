use Test;

use lib "lib";

use-ok "Test::Fuzz::Fuzzed";

{
	use Test::Fuzz::Fuzzed;

	my sub test-func (|c) {
		is-deeply c, \(42), Q"test-func received \(42)";
	};

	subtest {
		my &t1 = &test-func but Test::Fuzz::Fuzzed;

		can-ok &t1, "compose";
		can-ok &t1, "run-tests";
		&t1.compose;
		is &t1.signature.agg-generators, True;
	};

	subtest {
		my &t2 = &test-func but Test::Fuzz::Fuzzed[:returns(Int)];

		can-ok &t2, "compose";
		can-ok &t2, "run-tests";
		&t2.compose;
		is &t2.signature.agg-generators, True;
	};

	subtest {
		my &t3 = &test-func but Test::Fuzz::Fuzzed;

		can-ok &t3, "compose";
		can-ok &t3, "run-tests";

		&t3.signature does role {
			method generate-samples(Int() $size = 10) {
				lazy gather for ^$size {
					take \(42)
				}
			}
		}

		&t3.run-tests
	};
}

done-testing
