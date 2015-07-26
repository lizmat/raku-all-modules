use TAP::Entry;
use Test::Event;
use Test::Stream;

package TAP {
	class Generator {
		has Test::Stream $.stream handles <start-subtest stop-subtest tests-seen stop-tests>;
		submethod BUILD(TAP::Entry::Handler :$output, Int :$version = 12) {
			$!stream = Test::Stream.new(:$output, :$version);
		}

		multi method plan(Int $tests) {
			$!stream.emit(Test::Event::Plan.new(:tests($tests)));
		}
		multi method plan(Bool :$skip-all) {
			$!stream.emit(Test::Event::Plan.new(:tests(0), :skip-all));
		}
		multi method plan(TAP::Directive::Explanation :$skip-all) {
			$!stream.emit(Test::Event::Plan.new(:tests(0), :skip-all, :explanation($skip-all)));
		}

		method test(Bool :$ok, TAP::Test::Description :$description is copy, TAP::Directive :$directive = TAP::No-Directive, TAP::Directive::Explanation :$explanation) {
			$!stream.emit(Test::Event::Test.new(:$ok, :$description, :$directive, :$explanation));
		}
		method comment(Str $content) {
			$!stream.emit(Test::Event::Comment.new(:$content));
		}
	}
}
