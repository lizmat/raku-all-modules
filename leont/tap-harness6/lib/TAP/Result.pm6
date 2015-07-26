use TAP::Entry;
package TAP {
	class Result {
		has Str $.name;
		has Int $.tests-planned;
		has Int $.tests-run;
		has Int @.passed;
		has Int @.failed;
		has Str @.errors;
		has Int @.actual-passed;
		has Int @.actual-failed;
		has Int @.todo;
		has Int @.todo-passed;
		has Int @.skipped;
		has Int $.unknowns;
		has Bool $.skip-all;
		has Proc $.exit-status;
		has Duration $.time;
		method exit() {
			$!exit-status.defined ?? $!exit-status.exitcode !! Int;
		}
		method wait() {
			$!exit-status.defined ?? $!exit-status.status !! Int;
		}

		method has-problems() {
			@!todo || self.has-errors;
		}
		method has-errors() {
			return @!failed || @!errors || self.exit-failed;
		}
		method exit-failed() {
			return $!exit-status && $!exit-status.exitcode > 0;
		}
	}

	class Aggregator {
		has Result %.results-for;
		has Result @!parse-order;

		has Int $.parsed = 0;
		has Int $.tests-planned = 0;
		has Int $.tests-run = 0;
		has Int $.passed = 0;
		has Int $.failed = 0;
		has Str @.errors;
		has Int $.actual-passed = 0;
		has Int $.actual-failed = 0;
		has Int $.todo;
		has Int $.todo-passed;
		has Int $.skipped;
		has Bool $.exit-failed = False;

		method add-result(Result $result) {
			my $description = $result.name;
			die "You already have a parser for ($description). Perhaps you have run the same test twice." if %!results-for{$description};
			%!results-for{$description} = $result;
			@!parse-order.push($result);

			$!parsed++;
			$!tests-planned += $result.tests-planned // 1;
			$!tests-run += $result.tests-run;
			$!passed += $result.passed.elems;
			$!failed += $result.failed.elems;
			$!actual-passed += $result.actual-passed.elems;
			$!actual-failed += $result.actual-failed.elems;
			$!todo += $result.todo.elems;
			$!todo-passed += $result.todo-passed.elems;
			$!skipped += $result.skipped.elems;
			@!errors.push(@($result.errors));
			$!exit-failed = True if $result.exit-status && $result.exit-status.exitcode > 0;
		}

		method descriptions() {
			return @!parse-order».name;
		}

		method has-problems() {
			return $!todo-passed || self.has-errors;
		}
		method has-errors() {
			return $!failed || @!errors || $!exit-failed;
		}
		method get-status() {
			return self.has-errors || $!tests-run != $!passed ?? 'FAILED' !! $!tests-run ?? 'PASS' !! 'NOTESTS';
		}
	}
}
