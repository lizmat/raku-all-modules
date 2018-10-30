use Test;
use Test::META;
meta-ok;

use lib "lib";
use-ok "Test::Fuzz";

my \test-samples = 100;

for Int, Str -> \Type {
	can-ok Type, "generate-samples";
	for Type.generate-samples[^test-samples] -> $sample {
		isa-ok $sample, Type;
	}
}

done-testing
