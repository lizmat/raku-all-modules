use TAP::Harness;
use TAP::Entry;

use Test::More;

my $source = TAP::Runner::Source::Through.new(:name("Self-Testing"));
my $parser = TAP::Runner::Async.new(:$source);
my $elements = TAP::Collector.new();
my $output = TAP::Entry::Handler::Multi.new(:handlers($source, $elements));

my $tester = start {
	test-to $output, {
		plan(3);
		ok(True, "This tests passes");

		subtest 'Subtest', {
			pass();
			done-testing(1);
		};

		skip();
	}
}

is($tester.result, 0, 'Test would have returned 0');

my $result = $parser.result;
is($result.tests-planned, 3, 'Expected 3 tests');
is($result.tests-run, 3, 'Ran 3 tests');
is($result.passed.elems, 3, 'Passed 3 tests');
is($result.failed.elems, 0, 'Failed 0 tests');
is($result.todo-passed.elems, 0, 'Todo-passed 0 tests');
is($result.skipped.elems, 1, 'Skipped 1 test');

like($elements.entries[0], TAP::Plan, 'Expected a Plan');
like($elements.entries[1], TAP::Test, 'Expected a Test');
like($elements.entries[2], TAP::Sub-Test, 'Expected a Sub-Test');
is($elements.entries[2].entries.elems, 3, 'Expected 3 entries in subtest');
like($elements.entries[2].entries[0], TAP::Comment, 'Expected a Comment in subtest');
like($elements.entries[2].entries[1], TAP::Test, 'Expected a Test in subtest');
like($elements.entries[2].entries[2], TAP::Plan, 'Expected a Plan in subtest');
like($elements.entries[3], TAP::Test, 'Expected a Test');

done-testing();
