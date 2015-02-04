use TAP::Parser;
use TAP::Formatter;

class TAP::Harness {
	role SourceHandler {
		method can-handle {...};
		method make-async-source {...};
		method make-async-parser(Any :$name, :@handlers, Promise :$bailout) {
			my $source = self.make-async-source($name);
			return TAP::Parser::Async.new(:$source, :@handlers :$bailout);
		}
	}
	class SourceHandler::Perl6 does SourceHandler {
		method can-handle($name) {
			return 0.5;
		}
		method make-async-source($name) {
			return TAP::Parser::Source::Proc.new(:$name, :path($*EXECUTABLE), :args[$name]);
		}
	}

	has SourceHandler @.handlers = SourceHandler::Perl6.new();
	has Any @.sources;
	has TAP::Formatter:T $.formatter-class = TAP::Formatter::Console;

	class Run {
		has Promise $.done handles <result>;
		has Promise $!kill;
		method kill(Any $reason = True) {
			$!kill.keep($reason);
		}
	}

	method run(Int :$jobs = 1, Bool :$timer = False, TAP::Formatter :$formatter = $!formatter-class.new(:parallel($jobs > 1), :names(@.sources), :$timer)) {
		my @working;
		my $kill = Promise.new;
		my $aggregator = TAP::Aggregator.new();
		my $done = start {
			for @!sources -> $name {
				last if $kill;
				my $session = $formatter.open-test($name);
				my $parser = @!handlers.max(*.can-handle($name)).make-async-parser(:$name, :handlers[$session], :$kill);
				@working.push({ :$parser, :$session, :done($parser.done) });
				next if @working < $jobs;
				await Promise.anyof(@working»<done>, $kill);
				reap-finished();
			}
			await Promise.anyof(Promise.allof(@working»<done>), $kill) if @working && not $kill;
			reap-finished();
			if $kill {
				.kill for @working;
			}
			$formatter.summarize($aggregator, ?$kill);
			$aggregator;
		};
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
}
