use TAP::Entry;
use TAP::Result;

package TAP {
	enum Formatter::Volume <Silent ReallyQuiet Quiet Normal Verbose>;
	role Formatter {
		has Bool $.timer = False;
		has Formatter::Volume $.volume = Normal;
	}
	role Reporter {
		method summarize(TAP::Aggregator, Bool $interrupted) { ... }
		method open-test(Str $) { ... }
	}

	class TAP::Reporter::Text { ... }
	role Reporter::Text::Session does TAP::Session {
		has TAP::Reporter $.reporter;
		has Str $.name;
		has Str $.header;
		method clear-for-close() {
		}
		method close-test(TAP::Result $result) {
			$!reporter.print-result(self, $result);
		}
		method handle-entry(TAP::Entry $) {
		}
	}
	class Formatter::Text does Formatter {
		has Int $!longest;

		submethod BUILD(:@names) {
			$!longest = @names ?? @names».chars.max !! 12;
		}
		method format-name($name) {
			my $periods = '.' x ( $!longest + 2 - $name.chars);
			my @now = $.timer ?? ~DateTime.new(now, :formatter{ '[' ~ .hour ~ ':' ~ .minute ~ ':' ~ .second.Int ~ ']' }) !! ();
			return (@now, $name, $periods).join(' ');
		}
		method format-summary(TAP::Aggregator $aggregator, Bool $interrupted) {
			my @tests = $aggregator.descriptions;
			my $total = $aggregator.tests-run;
			my $passed = $aggregator.passed;
			my $output = '';

			if $interrupted {
				$output ~= self.format-failure("Test run interrupted!\n")
			}

			if $aggregator.failed == 0 {
				$output ~= self.format-success("All tests successful.\n");
			}

			if $total != $passed || $aggregator.has-problems {
				$output ~= "\nTest Summary Report";
				$output ~= "\n-------------------\n";
				for @tests -> $name {
					my $result = $aggregator.results-for{$name};
					if $result.has-problems {
						my $spaces = ' ' x min($!longest - $name.chars, 1);
						my $wait = $result.exit-status ?? 0 // '(none)' !! '(none)';
						my $line = "$name$spaces (Wstat: $wait Tests: {$result.tests-run} Failed: {$result.failed.elems})\n";
						$output ~= $result.has-errors ?? self.format-failure($line) !! $line;

						if $result.failed -> @failed {
							$output ~= self.format-failure('  Failed tests:  ' ~ @failed.join(' ') ~ "\n");
						}
						if $result.todo-passed -> @todo-passed {
							$output ~= "  TODO passed:  { @todo-passed.join(' ') }\n";
						}
						if $result.exit-status.defined { # XXX
							if $result.exit {
								$output ~= self.format-failure("Non-zero exit status: { $result.exit }\n");
							}
							elsif $result.wait {
								$output ~= self.format-failure("Non-zero wait status: { $result.wait }\n");
							}
						}
						if $result.errors -> @errors {
							my ($head, @tail) = @errors;
							$output ~= self.format-failure("  Parse errors: $head\n");
							for @tail -> $error {
								$output ~= self.format-failure(' ' x 16 ~ $error ~ "\n");
							}
						}
					}
				}
			}
			$output ~= "Files={ @tests.elems }, Tests=$total\n";
			my $status = $aggregator.get-status;
			$output ~= "Result: $status\n";
			return $output;
		}
		method format-success(Str $output) {
			return $output;
		}
		method format-failure(Str $output) {
			return $output;
		}
		method format-return(Str $output) {
			return $output;
		}
		method format-result(Reporter::Text::Session $session, TAP::Result $result) {
			my $output;
			my $name = $session.header;
			if ($result.skip-all) {
				$output = self.format-return("$name skipped");
			}
			elsif ($result.has-errors) {
				$output = self.format-test-failure($name, $result);
			}
			else {
				my $time = self.timer && $result.time ?? sprintf ' %8d ms', Int($result.time * 1000) !! '';
				$output = self.format-return("$name ok$time\n");
			}
			return $output;
		}
		method format-test-failure(Str $name, TAP::Result $result) {
			return if self.volume < Quiet;
			my $output = self.format-return("$name ");

			my $total = $result.tests-planned // $result.tests-run;
			my $failed = $result.failed + abs($total - $result.tests-run);

			if $result.exit -> $status {
				$output ~= self.format-failure("Dubious, test returned $status\n");
			}

			if $result.failed == 0 {
				$output ~= self.format-failure($total ?? "All $total subtests passed " !! 'No subtests run');
			}
			else {
				$output ~= self.format-failure("Failed {$result.failed}/$total subtests ");
				if (!$total) {
					$output ~= self.format-failure("\nNo tests run!");
				}
			}

			if $result.skipped.elems -> $skipped {
				my $passed = $result.passed.elems - $skipped;
				my $test = 'subtest' ~ ( $skipped != 1 ?? 's' !! '' );
				$output ~= "\n\t(less $skipped skipped $test: $passed okay)";
			}

			if $result.todo-passed.elems -> $todo-passed {
				my $test = $todo-passed > 1 ?? 'tests' !! 'test';
				$output ~= "\n\t($todo-passed TODO $test unexpectedly succeeded)";
			}

			$output ~= "\n";
			return $output;
		}
	}
	class Reporter::Text does Reporter {
		has IO::Handle $!handle;
		has Formatter::Text $!formatter;

		submethod BUILD(:@names, :$!handle = $*OUT, :$volume = Normal, :$timer = False) {
			$!formatter = Formatter::Text.new(:@names, :$volume, :$timer);
		}

		method open-test(Str $name) {
			my $header = $!formatter.format-name($name);
			return Formatter::Text::Session.new(:$name, :$header, :formatter(self));
		}
		method summarize(TAP::Aggregator $aggregator, Bool $interrupted) {
			self!output($!formatter.format-summary($aggregator, $interrupted));
		}
		method !output(Any $value) {
			$!handle.print($value);
		}
		method print-result(Reporter::Text::Session $session, TAP::Result $report) {
			self!output($!formatter.format-result($session, $report));
		}
	}

	class Formatter::Console is Formatter::Text {
		my &colored = do {
			try { require Term::ANSIColor }
			GLOBAL::Term::ANSIColor::EXPORT::DEFAULT::<&colored> // sub (Str $text, Str $) { $text };
		}
		method format-success(Str $output) {
			return colored($output, 'green');
		}
		method format-failure(Str $output) {
			return colored($output, 'red');
		}
		method format-return(Str $output) {
			return "\r$output";
		}
	}

	class Reporter::Console::Session does Reporter::Text::Session {
		has Int $!last-updated = 0;
		has Int $.plan = Int;
		has Int $.number = 0;
		proto method handle-entry(TAP::Entry $entry) {
			{*};
		}
		multi method handle-entry(TAP::Bailout $bailout) {
			my $explanation = $bailout.explanation // '';
			$!reporter.bailout($explanation);
		}
		multi method handle-entry(TAP::Plan $plan) {
			$!plan = $plan.tests;
		}
		multi method handle-entry(TAP::Test $test) {
			my $now = time;
			++$!number;
			if $!last-updated != $now {
				$!last-updated = $now;
				$!reporter.update($.name, $!header, $test.number // $!number, $!plan);
			}
		}
		multi method handle-entry(TAP::Entry $) {
		}
	}
	class Reporter::Console does Reporter {
		has Bool $.parallel;
		has Formatter::Console $!formatter;
		has Int $!lastlength;
		has Supply $events;
		has Reporter::Console::Session @!active;
		has Int $!tests;
		has Int $!fails;

		submethod BUILD(:@names, IO::Handle :$handle = $*OUT, :$volume = Normal, :$timer = False) {
			$!formatter = Formatter::Console.new(:@names, :$volume, :$timer);
			$!lastlength = 0;
			$!events = Supply.new;
			@!active .= new;

			my $now = 0;
			my $start = now;

			sub output-ruler(Bool $refresh) {
				my $new-now = now;
				return if $now == $new-now and !$refresh;
				$now = $new-now;
				return if $!formatter.volume < Quiet;
				my $header = sprintf '===( %7d;%d', $!tests, $now - $start;
				my @items = @!active.map(-> $active { sprintf '%' ~ $active.plan.chars ~ "d/%d", $active.number, $active.plan });
				my $ruler = ($header, @items).join('  ') ~ ')===';
				$handle.print($!formatter.format-return($ruler));
			}
			multi receive('update', Str $name, Str $header, Int $number, Int $plan) {
				if @!active.elems == 1 {
					my $status = ($header, $number, '/', $plan // '?').join('');
					$handle.print($!formatter.format-return($status));
					$!lastlength = $status.chars + 1;
				}
				else {
					output-ruler($number == 1);
				}
			}
			multi receive('bailout', Str $explanation) {
				$handle.print($!formatter.format-failure("Bailout called.  Further testing stopped: $explanation\n"));
			}
			multi receive('result', Reporter::Console::Session $session, TAP::Result $result) {
				$handle.print($!formatter.format-return(' ' x $!lastlength) ~ $!formatter.format-result($session, $result));
				@!active = @!active.grep(* !=== $session);
				output-ruler(True) if @!active.elems > 1;
			}
			multi receive('summary', TAP::Aggregator $aggregator, Bool $interrupted) {
				$handle.print($!formatter.format-summary($aggregator, $interrupted));
			}

			$!events.act(-> @args { receive(|@args) });
		}

		method update(Str $name, Str $header, Int $number, Int $plan) {
			$!events.emit(['update', $name, $header, $number, $plan]);
		}
		method bailout(Str $explanation) {
			$!events.emit(['bailout', $explanation]);
		}
		method print-result(Reporter::Console::Session $session, TAP::Result $result) {
			$!events.emit(['result', $session, $result]);
		}
		method summarize(TAP::Aggregator $aggregator, Bool $interrupted) {
			$!events.emit(['summary', $aggregator, $interrupted]);
		}

		method open-test(Str $name) {
			my $header = $!formatter.format-name($name);
			my $ret = Reporter::Console::Session.new(:$name, :$header, :reporter(self));
			@!active.push($ret);
			return $ret;
		}
	}
	class Formatter::Console::Parallel is Formatter::Console {
		method update(Str $name, Str $header, Int $number, Str $planstr) {
		}
		method clear(TAP::Result $result) {
			...;
		}
	}
}
