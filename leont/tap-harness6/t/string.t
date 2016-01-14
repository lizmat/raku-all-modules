use TAP;
use Test;

my $content1 = q:heredoc/END/;
    ok 1 - subtest 1a
    ok 2 - subtest 1b
    1..2
ok 1 - Subtest 1
    ok 1 - subtest 2a
    ok 2 - subtest 2b
    1..2
ok 2 - Subtest 2
1..2
END
parse-and-get($content1, :tests-planned(2), :tests-run(2), :passed(2), :failed(0), :todo-passed(0), :skipped(0), :unknowns(0), :errors());

my $content2 = q:heredoc/END/;
ok 1 - foo
    not ok 1 - not ok
ok 2 - bar passed
1..2
END
parse-and-get($content2, :tests-planned(2), :tests-run(2), :passed(2), :failed(0), :todo-passed(0), :skipped(0), :unknowns(0), :errors(['Subtest 2 isn\'t coherent', "Subtest 2 doesn't have a plan"]));

my $content3 = q:heredoc/END/;
ok 1 - foo
        ok 1 - bar indented too far
ok 2 - bar passed
1..2
END

parse-and-get($content3, :tests-planned(2), :tests-run(2), :passed(2), :failed(0), :todo-passed(0), :skipped(0), :unknowns(1), :errors());

my $content4 = q:heredoc/END/;
1..2
ok 1 - a
        ok 1 - b
        1..1
    ok 1 - c
    1..1
ok 2 - e
END

parse-and-get($content4, :tests-planned(2), :tests-run(2), :passed(2), :failed(0), :todo-passed(0), :skipped(0), :unknowns(0), :errors());

my @entries = lex-and-get($content4);
isa-ok(@entries[0], TAP::Plan, 'First Entry is a Plan');
isa-ok(@entries[1], TAP::Test, 'Second entry is a subtest');
isa-ok(@entries[2], TAP::Sub-Test, 'Third entry is a subtest');
is-deeply(@entries[2].inconsistencies, [], 'Subtests has no errors');
isa-ok(@entries[2].entries[0], TAP::Sub-Test, 'First sub-entry is a subtest');
is-deeply(@entries[2].entries[0].inconsistencies, [], 'Subsubtests has no errors');

my $content5 = q:heredoc/END/;
1..2
ok 1 - a\#b
    ok 1 - b
      ---
      - Foo
      - Bar
      ...
    1..1
ok 2 - c
END

parse-and-get($content5, :tests-planned(2), :tests-run(2), :passed(2), :failed(0), :todo-passed(0), :skipped(0), :unknowns(0), :errors());

my @entries2 = lex-and-get($content5);
isa-ok(@entries2[0], TAP::Plan, 'First Entry is a Plan');
isa-ok(@entries2[1], TAP::Test, 'Second entry is a test');
is(@entries2[1].description, 'a#b', 'Test has a description');
isa-ok(@entries2[2], TAP::Sub-Test, 'Third entry is a subtest');
is-deeply(@entries2[2].inconsistencies, [], 'Subtests has no errors');
isa-ok(@entries2[2].entries[1], TAP::YAML, 'Got YAML');
if try (require YAMLish) {
	is-deeply(@entries2[2].entries[1].deserialized, [ <Foo Bar> ], 'Could deserialize YAML');
}

done-testing();

my $i;
sub parse-and-get($content, :$tests-planned, :$tests-run, :$passed, :$failed, :$todo-passed, :$skipped, :$unknowns, :@errors = Array, :$name = "Test-{ ++$i }") {
	my $source = TAP::Runner::Source::String.new(:$name, :$content);
	my $parser = TAP::Runner::Async.new(:$source);

	my $result = $parser.result;
	is($result.tests-planned, $tests-planned, "Expected $tests-planned planned tests in $name") if $tests-planned.defined;
	is($result.tests-run, $tests-run, "Expected $tests-run run tests in $name") if $tests-run.defined;
	is($result.passed, $passed, "Expected $passed passed tests in $name") if $passed.defined;
	is($result.failed.elems, $failed, "Expected $failed failed tests in $name") if $failed.defined;
	is($result.todo-passed.elems, $todo-passed, "Expected $todo-passed todo-passed tests in $name") if $todo-passed.defined;
	is($result.skipped, $skipped, "Expected $skipped skipped tests in $name") if $skipped.defined;
	is($result.unknowns, $unknowns, "Expected $unknowns unknown tests in $name") if $unknowns.defined;
	is-deeply($result.errors, Array[Str].new(|@errors), 'Got expected errors: ' ~ @errors.map({qq{"$_"}}).join(', ')) if @errors.defined;

	return $result;
}

sub lex-and-get($content) {
	my $ret = TAP::Collector.new;
	my $lexer = TAP::Parser.new(:handlers[$ret]);
	$lexer.add-data($content);
	$lexer.close-data();
	return $ret.entries;
}
