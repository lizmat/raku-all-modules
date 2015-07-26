use Test::Event;

package Test {
	class Context::Sub { ... }
	role Context does TAP::Entry::Handler {
		has Int $.version;
		has Int $.tests-expected;
		has Int $.failed = 0;
		has Int $.tests-seen = 0;
		method emit(TAP::Entry) { ... }
		method subtest(Str $description) {
			return Context::Sub.new(:$description, :$!version);
		}
		method handle-entry(TAP::Entry $entry) {
			given ($entry) {
				when TAP::Plan {
					$!tests-expected = $entry.tests;
				}
				when TAP::Test {
					$!tests-seen++;
					$!failed++ if !$entry.is-ok();
				}
			}
			self.emit($entry);
		}
		method end-entries() {
			if $!tests-expected.defined && $!tests-seen != $!tests-expected {
				self.handle-entry(TAP::Comment.new(:comment("Expected $!tests-expected tests but seen $!tests-seen")));
			}
			elsif $!failed > 0 {
				self.handle-entry(TAP::Comment.new(comment => "Looks like you failed $!failed test of $!tests-seen."));
			}
		}
	}

	my class Context::Main does Context {
		has TAP::Entry::Handler:D $.output;
		method emit(TAP::Entry $entry) {
			$!output.handle-entry($entry);
		}
		method new(:$output, :$version) {
			$!output.handle-entry(TAP::Version.new($version)) if $version > 12;
			self.bless(:$output, :$version);
		}
	}
	my class Context::Sub does Context {
		has Str $.description;
		has TAP::Entry @!entries;
		method emit(TAP::Entry $entry) {
			@!entries.push($entry);
		}
		method end-entries() {
			if !$!tests-expected.defined {
				self.handle-entry(TAP::Plan.new(:tests($!tests-seen)));
			}
			callsame;
		}
		method give-test() {
			return TAP::Sub-Test.new(:ok(!$!failed), :$!description, :@!entries);
		}
	}
	class Stream {
		has TAP::Entry::Handler:D $.output;
		has Int $.version;
		has Context @!constack;
		has Context $!context handles <tests-seen handle-entry>;
		submethod BUILD(TAP::Entry::Handler :$!output, Int :$version = 12) {
			$!context = Context::Main.new(:$!output, :$version);
		}
		method start-subtest(Str $description) {
			@!constack.push($!context);
			$!context = $!context.subtest($description);
			$!context.handle-entry(TAP::Comment.new(:comment($description))) if $description.defined;
		}
		method stop-subtest() {
			if @!constack {
				$!context.end-entries();
				my $old = $!context;
				$!context = @!constack.pop;
				$!context.handle-entry($old.give-test());
			}
			else {
				fail 'No subtests to return from';
			}
		}
		method stop-tests() {
			self.stop-subtest() while @!constack;
			$!output.end-entries();
			return min($!context.failed, 254);
		}
		proto method emit($event) {
			{*};
		}
		multi method emit(Test::Event::Plan $plan) {
			$!context.handle-entry(TAP::Plan.new(:tests($plan.tests), :skip-all($plan.skip-all), :explanation($plan.explanation)));
		}
		multi method emit(Test::Event::Test $test) {
			my $number = $!context.tests-seen + 1;
			my $description = $test.description.defined ?? $test.description.subst(/ ( '\\' | '#' ) /, { "\\$_" }) !! TAP::Test::Description;
			$!context.handle-entry(TAP::Test.new(:ok($test.ok), :$number, :$description, :directive($test.directive), :explanation($test.explanation)));
		}
		multi method emit(Test::Event::Comment $comment ) {
			for @( $comment.content.split(/\n/) ) -> $line {
				$!context.handle-entry(TAP::Comment.new(:comment($line)));
			}
		}
	}
}
