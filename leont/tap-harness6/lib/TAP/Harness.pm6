use TAP::Parser;
use TAP::Entry;
use TAP::Result;
use TAP::Formatter;

package TAP::Runner {
	class State does TAP::Entry::Handler {
		has Range $.allowed-versions = 12 .. 13;
		has Int $!tests-planned;
		has Int $!tests-run = 0;
		has Int @!passed;
		has Int @!failed;
		has Str @!errors;
		has Int @!actual-passed;
		has Int @!actual-failed;
		has Int @!todo;
		has Int @!todo-passed;
		has Int @!skipped;
		has Int $!unknowns = 0;
		has Bool $!skip-all = False;

		has Promise $.bailout;
		has Int $!seen-lines = 0;
		enum Seen <Unseen Before After>;
		has Seen $!seen-plan = Unseen;
		has Promise $.done = Promise.new;
		has Int $!version;

		proto method handle-entry(TAP::Entry $entry) {
			if $!seen-plan == After && $entry !~~ TAP::Comment {
				self!add-error("Got line $entry after late plan");
			}
			{*};
			$!seen-lines++;
		}
		multi method handle-entry(TAP::Version $entry) {
			if $!seen-lines {
				self!add-error('Seen version declaration mid-stream');
			}
			elsif $entry.version !~~ $!allowed-versions {
				self!add-error("Version must be in range $!allowed-versions");
			}
			else {
				$!version = $entry.version;
			}
		}
		multi method handle-entry(TAP::Plan $plan) {
			if $!seen-plan != Unseen {
				self!add-error('Seen a second plan');
			}
			else {
				$!tests-planned = $plan.tests;
				$!seen-plan = $!tests-run ?? After !! Before;
				$!skip-all = $plan.skip-all;
			}
		}
		multi method handle-entry(TAP::Test $test) {
			my $found-number = $test.number;
			my $expected-number = ++$!tests-run;
			if $found-number.defined && ($found-number != $expected-number) {
				self!add-error("Tests out of sequence.  Found ($found-number) but expected ($expected-number)");
			}
			if $!seen-plan == After {
				self!add-error("Plan must be at the beginning or end of the TAP output");
			}

			my $usable-number = $found-number // $expected-number;
			($test.is-ok ?? @!passed !! @!failed).push($usable-number);
			($test.ok ?? @!actual-passed !! @!actual-failed).push($usable-number);
			@!todo.push($usable-number) if $test.directive == TAP::Todo;
			@!todo-passed.push($usable-number) if $test.ok && $test.directive == TAP::Todo;
			@!skipped.push($usable-number) if $test.directive == TAP::Skip;

			if $test ~~ TAP::Sub-Test {
				for $test.inconsistencies(~$usable-number) -> $error {
					self!add-error($error);
				}
			}
		}
		multi method handle-entry(TAP::Bailout $entry) {
			if $!bailout.defined {
				$!bailout.keep($entry);
			}
			else {
				$!done.break($entry);
			}
		}
		multi method handle-entry(TAP::Unknown $) {
			$!unknowns++;
		}
		multi method handle-entry(TAP::Entry $entry) {
		}

		method end-entries() {
			if $!seen-plan == Unseen {
				self!add-error('No plan found in TAP output');
			}
			elsif $!tests-run != $!tests-planned {
				self!add-error("Bad plan.  You planned $!tests-planned tests but ran $!tests-run.");
			}
			$!done.keep;
		}
		method finalize(Str $name, Proc $exit-status, Duration $time) {
			return TAP::Result.new(:$name, :$!tests-planned, :$!tests-run, :@!passed, :@!failed, :@!errors, :$!skip-all,
				:@!actual-passed, :@!actual-failed, :@!todo, :@!todo-passed, :@!skipped, :$!unknowns, :$exit-status, :$time);
		}
		method !add-error(Str $error) {
			push @!errors, $error;
		}
	}

	class Async { ... }

	role Source {
		has Str $.name;
		method make-parser(:@handlers, Promise :$promise) {
			return Async.new(:source(self), :@handlers, :$promise);
		}
	}
	my class Run {
		subset Killable of Any where *.can('kill');
		has Killable $!process;
		has Promise:D $.done;
		has Promise $.timer;
		method kill() {
			$!process.kill if $!process;
		}
		method exit-status() {
			return $!done.result ~~ Proc ?? $.done.result !! Proc;
		}
		method time() {
			return $!timer.defined ?? $!timer.result !! Duration;
		}
	}
	class Source::Proc does Source {
		has IO::Path $.path;
		has @.args;
	}
	class Source::File does Source {
		has Str $.filename;
	}
	class Source::String does Source {
		has Str $.content;
	}
	class Source::Through does Source does TAP::Entry::Handler {
		has Promise $.done = Promise.new;
		has TAP::Entry @!entries;
		has Supply $!input = Supply.new;
		has Supply $!supply = Supply.new;
		has Promise $.promise = $!input.Promise;
		method staple(TAP::Entry::Handler @handlers) {
			for @!entries -> $entry {
				@handlers».handle-entry($entry);
			}
			$!input.act({
				@handlers».handle-entry($^entry);
				@!entries.push($^entry);
			}, :done({ @handlers».end-entries() }));
		}
		method handle-entry(TAP::Entry $entry) {
			$!input.emit($entry);
		}
		method end-entries() {
			$!input.done();
		}
	}

	class Async {
		has Str $.name;
		has Run $!run;
		has State $!state;
		has Promise $.done;

		submethod BUILD(Str :$!name, State :$!state, Run :$!run) {
			$!done = Promise.allof($!state.done, $!run.done);
		}

		multi get_runner(Source::Proc $proc; TAP::Entry::Handler @handlers) {
			my $process = Proc::Async.new($proc.path, $proc.args);
			my $lexer = TAP::Parser.new(:@handlers);
			$process.stdout().act({ $lexer.add-data($^data) }, :done({ $lexer.close-data() }));
			my $done = $process.start();
			my $start-time = now;
			my $timer = $done.then({ now - $start-time });
			return Run.new(:$done, :$process, :$timer);
		}
		multi get_runner(Source::Through $through; TAP::Entry::Handler @handlers) {
			$through.staple(@handlers);
			return Run.new(:done($through.promise));
		}
		multi get_runner(Source::File $file; TAP::Entry::Handler @handlers) {
			my $lexer = TAP::Parser.new(:@handlers);
			return Run.new(:done(start {
				$lexer.add-data($file.filename.IO.slurp);
				$lexer.close-data();
			}));
		}
		multi get_runner(Source::String $string; TAP::Entry::Handler @handlers) {
			my $lexer = TAP::Parser.new(:@handlers);
			$lexer.add-data($string.content);
			$lexer.close-data();
			my $done = Promise.new;
			$done.keep;
			return Run.new(:$done);
		}

		method new(Source :$source, :@handlers, Promise :$bailout) {
			my $state = State.new(:$bailout);
			my TAP::Entry::Handler @all_handlers = $state, @handlers;
			my $run = get_runner($source, @all_handlers);
			return Async.bless(:name($source.name), :$state, :$run);
		}

		method kill() {
			$!run.kill();
			$!done.break("killed") if not $!done;
		}

		has TAP::Result $!result;
		method result {
			await $!done;
			return $!result //= $!state.finalize($!name, $!run.exit-status, $!run.time);
		}

	}

	class Sync {
		has Source $.source;
		has @.handlers;
		has Str $.name = $!source.name;

		method run(Promise :$bailout) {
			my $state = State.new(:$bailout);
			my TAP::Entry::Handler @handlers = $state, @!handlers;
			my $start-time = now;
			given $!source {
				when Source::Proc {
					my $parser = TAP::Parser.new(:@handlers);
					my $proc = run($!source.path, $!source.args, :out, :!chomp);
					for $proc.out.lines -> $line {
						$parser.add-data($line);
					}
					$parser.close-data();
					return $state.finalize($!name, $proc, now - $start-time);
				}
				when Source::Through {
					$!source.staple(@handlers);
					$!source.promise.result;
					return $state.finalize($!name, Proc, now - $start-time);
				}
				when Source::File {
					my $parser = TAP::Parser.new(:@handlers);
					$parser.add-data($!source.filename.IO.slurp);
					$parser.close-data();
					return $state.finalize($!name, Proc, now - $start-time);
				}
				when Source::String {
					my $parser = TAP::Parser.new(:@handlers);
					$parser.add-data($!source.content);
					$parser.close-data();
					return $state.finalize($!name, Proc, now - $start-time);
				}
			}
		}
	}
}

class TAP::Harness {
	role SourceHandler {
		method can-handle {...};
		method make-source {...};
	}
	class SourceHandler::Perl6 does SourceHandler {
		method can-handle($name) {
			return 0.5;
		}
		method make-source($name) {
			return TAP::Runner::Source::Proc.new(:$name, :path($*EXECUTABLE), :args[$name]);
		}
	}

	has SourceHandler @.handlers = SourceHandler::Perl6.new();
	has Any @.sources;
	has TAP::Reporter:T $.reporter-class = TAP::Reporter::Console;

	class Run {
		has Promise $.done handles <result>;
		has Promise $!kill;
		method kill(Any $reason = True) {
			$!kill.keep($reason);
		}
	}

	method run(Int :$jobs = 1, Bool :$timer = False) {
		my @working;
		my $kill = Promise.new;
		my $aggregator = TAP::Aggregator.new();
		my $reporter = $!reporter-class.new(:parallel($jobs > 1), :names(@.sources), :$timer, :$aggregator);
		if $jobs > 1 {
			my $done = start {
				for @!sources -> $name {
					last if $kill;
					my $session = $reporter.open-test($name);
					my $source = @!handlers.max(*.can-handle($name)).make-source($name);
					my $parser = TAP::Runner::Async.new(:$source, :handlers[$session], :$kill);
					@working.push({ :$parser, :$session, :done($parser.done) });
					next if @working < $jobs;
					await Promise.anyof(@working»<done>, $kill);
					reap-finished();
				}
				await Promise.anyof(Promise.allof(@working»<done>), $kill) if @working and not $kill;
				reap-finished();
				@working».kill if $kill;
				$reporter.summarize($aggregator, ?$kill);
				$aggregator;
			}
			sub reap-finished() {
				my @new-working;
				for @working -> $current {
					if $current<done> {
						$aggregator.add-result($current<parser>.result);
						$current<session>.close-test($current<parser>.result);
					}
					else {
						@new-working.push($current);
					}
				}
				@working = @new-working;
			}
			return Run.new(:$done, :$kill);
		}
		else {
			my $done = start {
				for @!sources -> $name {
					last if $kill;
					my $session = $reporter.open-test($name);
					my $source = @!handlers.max(*.can-handle($name)).make-source($name);
					my $parser = TAP::Runner::Sync.new(:$source, :handlers[$session]);
					my $result = $parser.run(:$kill);
					$aggregator.add-result($result);
					$session.close-test($result);
				}
				@working».kill if $kill;
				$reporter.summarize($aggregator, ?$kill);
				$aggregator;
			}
			return Run.new(:$done, :$kill);
		}
	}
}
