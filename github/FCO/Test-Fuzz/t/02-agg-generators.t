use Test;
use lib "lib";

use-ok "Test::Fuzz::AggGenerators";

subtest {
	use Test::Fuzz::AggGenerators;
	my $sig = :("Bla", Int $a, $b, Str :$c);

	$sig does Test::Fuzz::AggGenerators;
	is $sig.agg-generators, True;
	can-ok $sig, "compose";
	can-ok $sig, "generate-samples";

	$sig.compose;
	is $sig.params.grep(* !~~ Test::Fuzz::Generator).elems, 0;
};

subtest {
	use Test::Fuzz::AggGenerators;
	my $sig = :($a);

	$sig does Test::Fuzz::AggGenerators;
	is $sig.agg-generators, True;
	can-ok $sig, "compose";
	can-ok $sig, "generate-samples";

	for $sig.params -> $par {
		$par does role {
			method generate(Int() $size = 100) {
				gather for ^($size + 1) {
					take 42
				}
			}
		}
	}

	is-deeply $sig.generate-samples, \(42) xx 100;
};

subtest {
	use Test::Fuzz::AggGenerators;
	my $sig = :(:$a);

	$sig does Test::Fuzz::AggGenerators;
	is $sig.agg-generators, True;
	can-ok $sig, "compose";
	can-ok $sig, "generate-samples";

	for $sig.params -> $par {
		$par does role {
			method generate(Int() $size = 100) {
				gather for ^($size + 1) {
					take 42
				}
			}
		}
	}

	is-deeply $sig.generate-samples, \(:a(42)) xx 100;
};

subtest {
	use Test::Fuzz::AggGenerators;
	my $sig = :($a, :$b);

	$sig does Test::Fuzz::AggGenerators;
	is $sig.agg-generators, True;
	can-ok $sig, "compose";
	can-ok $sig, "generate-samples";

	for $sig.params -> $par {
		$par does role {
			method generate(Int() $size = 100) {
				gather for ^($size + 1) {
					take 42
				}
			}
		}
	}

	is-deeply $sig.generate-samples, \(42, :b(42)) xx 100;
};

done-testing
