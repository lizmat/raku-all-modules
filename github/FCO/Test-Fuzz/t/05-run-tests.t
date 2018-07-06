use Test;
plan 14;

use lib "lib";

use Test;
use-ok "Test::Fuzz";

{
	use Test::Fuzz;

	my $f = sub f() {} but role {method run-tests {pass "runned run-tests"}};
	Test::Fuzz::add-func($f);

	my $g = sub g() {} but role {method run-tests {pass "runned run-tests"}};
	Test::Fuzz::add-func($g);

	my $h = sub h() {} but role {method run-tests {pass "runned run-tests"}};
	Test::Fuzz::add-func($h);

	run-tests;
}

{
	use Test::Fuzz;

	my $f = sub f2() {} but role {method run-tests {pass "runned run-tests"}};
	Test::Fuzz::add-func($f);

	my $g = sub g2() {} but role {method run-tests {pass "runned run-tests"}};
	Test::Fuzz::add-func($g);

	my $h = sub h2() {} but role {method run-tests {flunk "shuldn't run h2"}};
	Test::Fuzz::add-func($h);

	run-tests <f2 g2>;
}

{
	use Test::Fuzz;

	my $runs = (1..100).pick; #Number of fuzzy tests to run.
	my $real-runs = 0;        #Number of fuzzy tests actually run.
	sub func(Int $a) is fuzzed { ++$real-runs; }

	run-tests @('func'), :$runs;

	ok $runs == $real-runs, "Runs: $runs, Real-Runs: $real-runs";
}

{
	use Test::Fuzz;

	my $runs = (1..100).pick;    #Number of fuzzy tests to run.
	my @real-runs is default(0); #Increcmentor.

	#Make a multi sub to play with.
	multi sub func(Int $a) { ++@real-runs[0]; }
	multi sub func(Str $a) { ++@real-runs[1]; }

	#Add the multi sub to the fuzz list.
	fuzz &func;
	run-tests @('func'), :$runs;

	#Make sure each function has the correct number of runs.
	for @real-runs -> $real {
		is $real, $runs, 'Can fuzz a multi sub.';
	}
}
