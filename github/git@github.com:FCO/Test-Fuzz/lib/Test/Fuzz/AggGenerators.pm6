class ToRemove is Any {}

#| Test::Fuzz::AggGenerators: Role to be "does"ed on function signatures
role Test::Fuzz::AggGenerators {
	use Test::Fuzz::Generator;

	has $.agg-generators = True;

	method params {...}

	method compose {
		for @( self.params ) -> $attr {
			$attr does Test::Fuzz::Generator;
		}
		nextsame;
	}

	method !build-possibilities(Int $size) {
		my @tmp;
		my %params = $.params.categorize: {.named ?? "named" !! "positional"}
		for @( %params<positional>.grep: {.defined} ) -> $attr {
			@tmp.push: $attr.generate($size / $.params.elems)
		}
		for @( %params<named>.grep: {.defined} ) -> $attr {
			my $name = $attr.name.subst(/^^ <[@$%&\\]>/, "");
			@tmp.push: $attr.generate($size / $.params.elems).map: $name => *
		}
		|@tmp
	}

	#| generate Captures for the signature
	method generate-samples(Int:D $size = 100 --> Iterable) {
		([X] self!build-possibilities($size), ToRemove.new)
			.pick($size)
			.map({.grep(* !~~ ToRemove).Array})
			.map: {.Capture};
	}
}
