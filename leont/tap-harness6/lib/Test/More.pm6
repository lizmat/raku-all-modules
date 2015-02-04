use TAP::Entry;
use TAP::Generator;

module Test::More {
	my sub generator() {
		state $generator;
		return $*tap-generator // $generator //= TAP::Generator.new(:output(TAP::Output.new));
	}

	multi plan(Int $tests) is export {
		if generator.tests-seen {
			die "Can't produce plan in the middle of testing";
		}
		generator.plan($tests);
	}
	multi plan(Bool :$skip-all) is export {
		if generator.tests-seen {
			die "Can't produce plan in the middle of testing";
		}
		generator.plan(:skip-all);
	}
	multi done-testing() is export {
		generator.plan(generator.tests-seen);
	}
	multi done-testing(Int $count) is export {
		generator.plan($count);
	}

	our $TODO is export = Str;

	my sub test-args() {
		return $TODO.defined ?? %(:directive(TAP::Todo), :explanation($TODO)) !! ();
	}

	sub ok(Mu $value, TAP::Test::Description $description = Str) is export {
		generator.test(:ok(?$value), :$description);
		return ?$value;
	}

	sub is(Mu $got, Mu $expected, TAP::Test::Description $description = Str) is export {
		$got.defined; # Hack to deal with Failures
		my $ok = $got eq $expected;
		generator.test(:$ok, :$description, |test-args());
		if !$ok {
			generator.comment("expected: '{$expected.gist}'\n     got: '{$got.gist}'");
		}
		return $ok;
	}
	sub isnt(Mu $got, Mu $expected, TAP::Test::Description $description = Str) is export {
		$got.defined; # Hack to deal with Failures
		my $ok = $got ne $expected;
		generator.test(:$ok, :$description, |test-args());
		if !$ok {
			generator.comment("twice: '{$got.gist}'");
		}
		return $ok;
	}
	sub like(Mu $got, Mu $expected, TAP::Test::Description $description = Str) is export {
		$got.defined; # Hack to deal with Failures
		my $ok = $got ~~ $expected;
		generator.test(:$ok, :$description, |test-args());
		if !$ok {
			generator.comment("expected: {$expected.perl}\n     got: '{$got.gist}'");
		}
		return $ok;
	}

	sub cmp-ok(Mu $got, Any $op, Mu $expected, TAP::Test::Description $description = Str) is export {
		$got.defined; # Hack to deal with Failures
		my $ok;
		if $op ~~ Callable ?? $op !! try EVAL "&infix:<$op>" -> $matcher {
			$ok = $matcher($got,$expected);
			generator.test(:$ok, :$description, |test-args());
			if !$ok {
				generator.comment("expected: '{$expected.gist}'");
				generator.comment(" matcher: '$matcher'");
				generator.comment("     got: '{$got.gist}'");
			}
			return $ok;
		}
		else {
			generator.test(:!ok, $description);
			generator.comment("Could not use '$op' as a comparator");
			return False;
		}
	}

	sub is-deeply(Mu $got, Mu $expected, TAP::Test::Description $description = Str) is export {
		my $ok = $got eqv $expected;
		generator.test(:$ok, :$description, |test-args());
		if !$ok {
			my $got_perl      = try { $got.perl };
			my $expected_perl = try { $expected.perl };
			if $got_perl.defined && $expected_perl.defined {
				generator.comment("expected: $expected_perl\n     got: $got_perl");
			}
		}
		return $ok;
	}


	sub pass(TAP::Test::Description $description = Str) is export {
		generator.test(:ok, :$description, |test-args());
		return True;
	}
	sub flunk(TAP::Test::Description $description = Str) is export {
		generator.test(:!ok, :$description, |test-args());
		return False;
	}

	sub skip(TAP::Directive::Explanation $explanation = Str, Int $count = 1) is export {
		for 1 .. $count {
			generator.test(:ok, :directive(TAP::Skip), :$explanation);
		}
	}

	multi subtest(&subtests) is export {
		generator.start-subtest();
		subtests();
		LEAVE {
			generator.stop-subtest();
		}
	}
	multi subtest(TAP::Test::Description $description, &subtests) is export {
		generator.start-subtest($description);
		subtests();
		LEAVE {
			generator.stop-subtest();
		}
	}

	sub diag(Str $comment) is export {
		generator.comment($comment);
		return True;
	}

	sub test-to(TAP::Entry::Handler $output, &tests, Bool :$keep-alive, Int :$version = 12) is export {
		my $*tap-generator = TAP::Generator.new(:$output, :$version);
		tests();
		my $ret = 0;
		LEAVE {
			$ret = generator.stop-tests() if not $keep-alive;
		}
		return $ret;
	}

	END {
		generator.stop-tests();
	}
}
