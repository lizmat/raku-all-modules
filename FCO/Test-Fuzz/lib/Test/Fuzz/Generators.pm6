#| Augmenting classes to create generate-samples method
unit module Test::Fuzz::Generators;
use MONKEY-TYPING;
augment class Int {
	method generate-samples(::?CLASS:U:) {
		gather {
			take 0;
			take -0;
			take 1;
			take -1;
			take 3;
			take -3;
			take 9999999999;
			take -9999999999;
			take $_ for (-10000000000^..^10000000000).roll(*)
		}
	}
}

augment class Str {
	method generate-samples(::?CLASS:U:) {
		gather {
			take "";
			take "a";
			take "a" x 99999;
			take "áéíóú";
			take "\n";
			take "\r";
			take "\t";
			take "\r\n";
			take "\r\t\n";
			loop {
				take (0.chr .. 0xc3bf.chr).roll((^999).pick).join
			}
		}
	}
}
