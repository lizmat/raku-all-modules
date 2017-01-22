use Test;
use lib "lib";

use MONKEY-TYPING;
augment class Int {
	method generate-samples(::?CLASS:U:) {
		gather {
			.take for ^1000;
		}
	}
}
use-ok "Test::Fuzz::Generator";

{
	use Test::Fuzz::Generator;
	my $sig = :(Int $a, "bla");

	subtest {
		my $param1 = $sig.params[0];
		$param1 does Test::Fuzz::Generator;
		is $param1.fuzz-generator, True;

		can-ok $param1, "generate";
		my %ret1 = $param1.generate.classify: {.defined ?? "defined" !! "undefined"};
		is-deeply %ret1<defined>, ^100 .Array;
		is-deeply %ret1<undefined>.Set, set(UInt,IntStr,Int,Bool,int,Order);
	}

	subtest {
		my $param2 = $sig.params[1];
		$param2 does Test::Fuzz::Generator;

		can-ok $param2, "generate";
		my %ret2 = $param2.generate.classify: {.defined ?? "defined" !! "undefined"};
		for @( %ret2<defined> ) -> $sample {
			is $sample, "bla"
		}
		is-deeply %ret2<undefined>.Set, set(Any);
	}
}

done-testing
