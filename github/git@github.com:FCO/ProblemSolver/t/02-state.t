use lib "lib";
use Test;

use-ok "ProblemSolver::State";
use ProblemSolver::State;
my $state = ProblemSolver::State.new;

ok $state, "Create State obj";

$state.add-variable: "var1", ^10;
is		$state.found-hash,			{};
is		$state.found-vars,			set();
is		$state.not-found-vars,		set("var1");
nok		$state.found-everything;
is		$state.next-var,			"var1";
nok		$state.has-empty-vars;

my @values;
for @( $state.iterate-over("var1") ) -> $state {
	@values.push: my $v = $state.get("var1");

	is		$state.found-hash,			{:var1($v)};
	is		$state.found-vars,			set <var1>;
	is		$state.not-found-vars,		set();
	ok		$state.found-everything;
	is		$state.next-var,			Nil;
	nok		$state.has-empty-vars;
	is		$state.Hash,				$state.found-hash;
}
is @values.sort, ^10;

$state.remove-from: "var1", ^10;
ok $state.has-empty-vars;

$state.add-variable: "var1", 1;
is		$state.found-hash,			{:var1(1)};
is		$state.found-vars,			set <var1>;
is		$state.not-found-vars,		set();
ok		$state.found-everything;
is		$state.next-var,			Nil;
nok		$state.has-empty-vars;

done-testing;
