#! perl6
use TAP::Harness;
use TAP::Entry;
use TAP::Generator;

my $source = TAP::Runner::Source::Through.new(:name<Self-Testing>);
my $parser = TAP::Runner::Async.new(:$source);
my $elements = TAP::Collector.new();
my $g = TAP::Generator.new(:output(TAP::Entry::Handler::Multi.new(:handlers($source, $elements))));

my $tester = start {
	$g.plan(3);
	$g.test(:ok, :description("This tests passes"));

	$g.start-subtest("subtest");
	$g.test(:ok);
	$g.plan(1);
	$g.stop-subtest();

	$g.test(:ok, :directive(TAP::Skip));

	$g.stop-tests();
};

my $h = TAP::Generator.new(:output(TAP::Output.new));

$h.test(:ok($tester.result == 0), :description('Test would have returned 0'));

my $result = $parser.result;
$h.test(:ok($result.tests-planned == 3), :description('Expected 3 test'));
$h.test(:ok($result.tests-run == 3), :description('Ran 3 test'));
$h.test(:ok($result.passed == 3), :description('Passed 3 tests'));
$h.test(:ok($result.failed == 0), :description('Failed 0 tests'));
$h.test(:ok($result.todo-passed == 0), :description('Todo-passed 0 tests'));
$h.test(:ok($result.skipped == 1), :description('Skipped 1 test'));

my @expected =
	TAP::Plan,
	TAP::Test,
	TAP::Sub-Test,
	TAP::Test,
	TAP::Test,
;

for $elements.entries Z @expected -> ($got, $expected) {
	my $ok = $got ~~ $expected;
	$h.test(:$ok, :description("Expected a " ~ $expected.WHAT.perl));
	if !$ok {
		$h.comment("Expected {$expected.WHAT.perl}, got a {$got.WHAT.perl}");
	}
}
$h.plan($h.tests-seen);
$h.stop-tests();

