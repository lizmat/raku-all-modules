package TAP {
	role Entry {
		has Str $.raw;
		method to-string { ... }
		method Str {
			return $.raw // $.to-string;
		}
	}
	class Version does Entry {
		has Int:D $.version;
		method to-string() {
			return "TAP Version $!version";
		}
	}
	class Plan does Entry {
		has Int:D $.tests = !!! 'tests is required';
		has Bool $.skip-all;
		has Str $.explanation;
		method to-string() {
			return ('1..' ~ $!tests, ($!skip-all ?? ('#SKIP', $!explanation).grep(*.defined) !! () )).join(' ');
		}
	}

	enum Directive <No-Directive Skip Todo>;
	subset Directive::Explanation of Str where { not .defined or m/ ^ \N* $ / };

	class Test does Entry {
		has Bool:D $.ok;
		has Int $.number;
		has Str $.description;
		has Directive:D $.directive = No-Directive;
		has Str $.explanation;

		method is-ok() {
			return $!ok || $!directive ~~ Todo;
		}
		method to-string() {
			my @ret = ($!ok ?? 'ok' !! 'not ok'), $!number, '-', $!description;
			@ret.push('#'~$!directive.uc, $!explanation) if $!directive;
			return @ret.grep(*.defined).join(' ');
		}
	}
	subset Test::Description of Str where { not .defined or m/ ^ \N* $ / };

	class Sub-Test is Test {
		has @.entries;

		method inconsistencies(Str $usable-number = ~$.number // '?') {
			my @errors;
			my @tests = @!entries.grep(Test);
			if $.ok != ?all(@tests).is-ok {
				@errors.push: "Subtest $usable-number isn't coherent";
			}
			my @plans = @!entries.grep(Plan);
			if !@plans {
				@errors.push: "Subtest $usable-number doesn't have a plan";
			}
			elsif @plans > 1 {
				@errors.push: "Subtest $usable-number has multiple plans";
			}
			elsif @plans[0].tests != @tests.elems {
				@errors.push: "Subtest $usable-number expected { @plans[0].tests } but contains { @tests.elems } tests";
			}
			return @errors;
		}
		method to-string() {
			return (@!entries».to-string()».indent(4), callsame).join("\n");
		}
	}

	class Bailout does Entry {
		has Str $.explanation;
		method to-string {
			return ('Bail out!', $.explanation).grep(*.defined).join(' ');
		}
	}
	class Comment does Entry {
		has Str:D $.comment;
		method to-string {
			return "# $!comment";
		}
	}
	class YAML does Entry {
		has Str:D $.content;
		method to-string {
			return "  ---\n" ~ $!content.indent(2) ~~ '  ...'
		}
	}
	class Unknown does Entry {
		method to-string {
			$!raw // fail 'Can\'t stringify empty Unknown';
		}
	}

	role Entry::Handler {
		method handle-entry(Entry) { ... }
		method end-entries() { }
	}

	role Session does Entry::Handler {
		method close-test() { ... }
	}

	class Output does Entry::Handler {
		has IO::Handle $.handle = $*OUT;
		method handle-entry(Entry $entry) {
			$!handle.say(~$entry);
		}
		method end-entries() {
			$!handle.flush;
		}
		method open(Str $filename) {
			my $handle = open $filename, :w;
			$handle.autoflush(True);
			return Output.new(:$handle);
		}
	}

	class Entry::Handler::Multi does Entry::Handler {
		has @!handlers;
		submethod BUILD(:@handlers) {
			@!handlers = @handlers;
		}
		method handle-entry(Entry $entry) {
			for @!handlers -> $handler {
				$handler.handle-entry($entry);
			}
		}
		method end-entries() {
			for @!handlers -> $handler {
				$handler.end-entries();
			}
		}
		method add-handler(Entry::Handler $handler) {
			@!handlers.push($handler);
		}
	}

	class Collector does Entry::Handler {
		has @.entries;
		submethod BUILD() {
		}
		method handle-entry(Entry $entry) {
			@!entries.push($entry);
		}
	}
}
