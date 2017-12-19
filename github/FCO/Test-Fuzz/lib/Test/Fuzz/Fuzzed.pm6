#| role Test::Fuzz::Fuzzed: Role that will be "does"ed on the fuzzes function
#| has 2 optional parameters
unit role Test::Fuzz::Fuzzed[
	:$returns,	#= :$returns
	:&test		#= :&test
];
use Test::Fuzz::AggGenerators;
use Test;

has $.fuzzed = True;
has Capture		@.data;
has 			$.returns	= $returns;
has				&.test		= &test;

#| required signature method
method signature {...}

method compose {
	die "Test function should receive 0 or 1 argument, but its receives {&!test.arity}" if &!test.defined and &!test.arity > 1;
	$.signature does Test::Fuzz::AggGenerators;
	$.signature.compose;
	nextsame;
}

#| Get the sample from the signature and use it for tests
method run-tests(Int:D $size = 100) {
	subtest {
		@!data = $.signature.generate-samples($size);
		my Int $tests = 0;
		for @.data -> $data {
			++$tests;
			my $return = self.(|$data);
			$return.exception.throw if $return ~~ Failure;
			CATCH {
				default {
					lives-ok {
						.throw
					}, "{ $.name }{ $data.perl.subst(/\\/, "") }"
				}
			}
			if &!test.defined {
				my $resp;
				if &!test.arity == 1 {
					$resp = &!test.($return)
				} elsif &!test.arity == 0 {
					$resp = so &!test.() == $return
				}
				flunk "{ $.name }({ $data.perl.subst(/\\/, "") })" unless $resp
			}
			pass "{ $.name }{ $data.perl.subst(/\\/, "") }"
		}
		flunk "Can not generate parameters for this function" if $tests == 0;
	}, $.name
}
