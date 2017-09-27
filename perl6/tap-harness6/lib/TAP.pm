use v6;

unit package TAP;
role Entry {
    has Str:D $.raw is required handles <Str>;
}
class Version does Entry {
    has Int:D $.version is required;
}
class Plan does Entry {
    has Int:D $.tests is required;
    has Bool $.skip-all;
    has Str $.explanation;
}

enum Directive <No-Directive Skip Todo>;

class Test does Entry {
    has Bool:D $.ok is required;
    has Int $.number;
    has Str $.description;
    has Directive:D $.directive = No-Directive;
    has Str $.explanation;

    method is-ok() {
        $!ok || $!directive ~~ Todo;
    }
}

class Sub-Test is Test {
    has @.entries;

    method inconsistencies(Str $usable-number = ~($.number // '?')) {
        my @errors;
        my @tests = @!entries.grep(Test);
        if $.is-ok != ?all(@tests).is-ok {
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
        @errors;
    }
}

class Bailout does Entry {
    has Str $.explanation;
}
class Comment does Entry {
    has Str:D $.comment is required;
}
class YAML does Entry {
    has Str:D $.serialized is required;
    has Any $.deserialized;
}
class Unknown does Entry {
}

my role Entry::Handler {
    method handle-entry(Entry) { ... }
    method end-entries() { }
    method listen(Supply $supply) {
        $supply.act(-> $entry {
                self.handle-entry($entry);
            },
            done => {
                self.end-entries();
            },
            quit => {
                self.end-entries();
            }
        );
    }
}

class Result {
    has Str $.name;
    has Int $.tests-planned;
    has Int $.tests-run;
    has Int $.passed;
    has Int @.failed;
    has Str @.errors;
    has Int $.actual-passed;
    has Int $.actual-failed;
    has Int $.todo;
    has Int @.todo-passed;
    has Int $.skipped;
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

    method has-problems($ignore-exit) {
        @!failed || @!errors || (!$ignore-exit && self.exit-failed);
    }
    method exit-failed() {
        $!exit-status.defined && $!exit-status.status;
    }
}

class Aggregator {
    has Result %!results-for;
    has Str @!parse-order;

    has Int $.tests-planned = 0;
    has Int $.tests-run = 0;
    has Int $.passed = 0;
    has Int $.failed = 0;
    has Int $.errors = 0;
    has Int $.actual-passed = 0;
    has Int $.actual-failed = 0;
    has Int $.todo = 0;
    has Int $.todo-passed = 0;
    has Int $.skipped = 0;
    has Int $.exit-failed = 0;
    has Bool $.ignore-exit = False;

    method add-result(Result $result) {
        my $description = $result.name;
        die "You already have a parser for ($description). Perhaps you have run the same test twice." if %!results-for{$description};
        %!results-for{$description} = $result;
        @!parse-order.push($result.name);

        $!tests-planned += $result.tests-planned // 0;
        $!tests-run += $result.tests-run;
        $!passed += $result.passed;
        $!failed += $result.failed.elems;
        $!actual-passed += $result.actual-passed;
        $!actual-failed += $result.actual-failed;
        $!todo += $result.todo;
        $!todo-passed += $result.todo-passed.elems;
        $!skipped += $result.skipped.elems;
        $!errors += $result.errors.elems;
        $!exit-failed++ if not $!ignore-exit and $result.wait;
    }

    method result-count {
        +@!parse-order;
    }
    method results() {
        %!results-for{@!parse-order};
    }


    method has-problems() {
        $!todo-passed || self.has-errors;
    }
    method has-errors() {
        $!failed + $!errors + $!exit-failed;
    }
    method get-status() {
        self.has-errors || $!tests-run != $!passed ?? 'FAILED' !! $!tests-run ?? 'PASS' !! 'NOTESTS';
    }
}

my grammar Grammar {
    regex TOP {
        ^ [ <plan> | <test> | <bailout> | <version> | <comment> || <unknown> ] $
    }
    token sp { <[\s] - [\n]> }
    token num { <[0..9]>+ }
    token plan {
        '1..' <count=.num> <.sp>* [
            '#' <.sp>* $<directive>=[:i 'SKIP'] \S*
            [ <.sp>+ $<explanation>=[\N*] ]?
        ]?
    }
    regex description {
        [ '\\\\' || '\#' || <-[\n#]> ]+ <!after <sp>+>
    }
    token test {
        $<nok>=['not '?] 'ok' [ <.sp> <num> ]? ' -'?
            [ <.sp>* <description> ]?
            [
                <.sp>* '#' <.sp>* $<directive>=[:i [ 'SKIP' \S* | 'TODO'] ]
                [ <.sp>+ $<explanation>=[\N*] ]?
            ]?
            <.sp>*
    }
    token bailout {
        'Bail out!' [ <.sp> $<explanation>=[\N*] ]?
    }
    token version {
        :i 'TAP version ' <version=.num>
    }
    token comment {
        '#' <.sp>* $<comment>=[\N*]
    }
    token yaml(Int $indent = 0) {
        '  ---' \n
        [ ^^ <.indent($indent)> '  ' $<yaml-line>=[<!before '...'> \N* \n] ]*
        <.indent($indent)> '  ...'
    }
    token sub-entry(Int $indent) {
        <plan> | <test> | <comment> | <yaml($indent)> | <sub-test($indent)> || <!before <.sp> > <unknown>
    }
    token indent(Int $indent) {
        '    ' ** { $indent }
    }
    token sub-test(Int $indent = 0) {
        '    '
        [ <sub-entry($indent + 1)> \n ]+ % [ <.indent($indent+1)> ]
        <.indent($indent)> <test>
    }
    token unknown {
        \N*
    }
    class Actions {
        method TOP($/) {
            make $/.values[0].made;
        }
        method plan($/) {
            my %args = :raw(~$/), :tests(+$<count>);
            if $<directive> {
                %args<skip-all explanation> = True, ~$<explanation>;
            }
            make TAP::Plan.new(|%args);
        }
        method description($/) {
            make ~$/.subst(/\\('#'|'\\')/, { $_[0] }, :g)
        }
        method !make_test($/) {
            my %args = (:ok($<nok> eq ''));
            %args<number> = $<num> ?? +$<num> !! Int;
            %args<description> = $<description>.made if $<description>;
            %args<directive> = $<directive> ?? TAP::Directive::{~$<directive>.substr(0,4).tclc} !! TAP::No-Directive;
            %args<explanation> = ~$<explanation> if $<explanation>;
            %args;
        }
        method test($/) {
            make TAP::Test.new(:raw(~$/), |self!make_test($/));
        }
        method bailout($/) {
            make TAP::Bailout.new(:raw(~$/), :explanation($<explanation> ?? ~$<explanation> !! Str));
        }
        method version($/) {
            make TAP::Version.new(:raw(~$/), :version(+$<version>));
        }
        method comment($/) {
            make TAP::Comment.new(:raw(~$/), :comment(~$<comment>));
        }
        method yaml($/) {
            my $serialized = $<yaml-line>.join('');
            my $deserialized = try (require YAMLish) ?? YAMLish::load-yaml("---\n$serialized...") !! Any;
            make TAP::YAML.new(:raw(~$/), :$serialized, :$deserialized);
        }
        method sub-entry($/) {
            make $/.values[0].made;
        }
        method sub-test($/) {
            make TAP::Sub-Test.new(:raw(~$/), :entries(@<sub-entry>».made), |self!make_test($<test>));
        }
        method unknown($/) {
            make TAP::Unknown.new(:raw(~$/));
        }
    }
    method parse(|c) {
        my $*tap-indent = 0;
        nextwith(:actions(Actions), |c);
    }
    method subparse(|c) {
        my $*tap-indent = 0;
        nextwith(:actions(Actions), |c);
    }
}

my sub parser(Supply $input --> Supply) {
    supply {
        enum Mode <Normal SubTest Yaml >;
        my Mode $mode = Normal;
        my Str @buffer;
        sub set-state(Mode $new, Str $line) {
            $mode = $new;
            @buffer = $line;
        }
        sub emit-unknown(*@more) {
            @buffer.append: @more;
            for @buffer -> $raw {
                emit Unknown.new(:$raw);
            }
            @buffer = ();
            $mode = Normal;
        }
        sub emit-reset(Match $entry) {
            emit $entry.made;
            @buffer = ();
            $mode = Normal;
        }

        my token indented { ^ '    ' }

        my $grammar = Grammar.new;

        whenever $input.lines -> $line {
            if $mode == Normal {
                if $line ~~ / ^ '  ---' / {
                    set-state(Yaml, $line);
                }
                elsif $line ~~ &indented {
                    set-state(SubTest, $line);
                }
                else {
                    emit-reset $grammar.parse($line);
                }
            }
            elsif $mode == SubTest {
                if $line ~~ &indented {
                    @buffer.push: $line;
                }
                elsif $grammar.parse($line, :rule('test')) -> $test {
                    my $raw = (|@buffer, $line).join("\n");
                    if $grammar.parse($raw, :rule('sub-test')) -> $subtest {
                        emit-reset $subtest;
                    }
                    else {
                        emit-unknown;
                        emit-reset $test;
                    }
                }
                else {
                    emit-unknown $line;
                }
            }
            elsif $mode == Yaml {
                if $line ~~ / ^ '  '  $<content>=[\N*] $ / {
                    @buffer.push: $line;
                    if $<content> eq '...' {
                        my $raw = @buffer.join("\n");
                        if $grammar.parse($raw, :rule('yaml')) -> $yaml {
                            emit-reset $yaml;
                        }
                        else {
                            emit-unknown;
                        }
                    }
                }
                else {
                    emit-unknown $line;
                }
            }
        }
        LEAVE { emit-unknown }
    }
}

enum Formatter::Volume <Silent ReallyQuiet Quiet Normal Verbose>;
role Formatter {
    has Bool:D $.timer = False;
    has Formatter::Volume $.volume = Normal;
    has Bool:D $.ignore-exit = False;
}
role Reporter {
    method summarize(TAP::Aggregator, Bool $interrupted, Duration $duration) { ... }
    method open-test(Str $) { ... }
}

role Session does Entry::Handler {
    has TAP::Reporter $.reporter;
    has Str $.name;
    has Str $.header;
    method clear-for-close() {
    }
    method close-test(TAP::Result $result) {
        $!reporter.print-result(self, $result);
    }
}

class Reporter::Text::Session does Session {
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
        (|@now, $name, $periods).join(' ');
    }
    method format-summary(TAP::Aggregator $aggregator, Bool $interrupted, Duration $duration) {
        my $output = '';

        if $interrupted {
            $output ~= self.format-failure("Test run interrupted!\n")
        }

        if $aggregator.failed == 0 {
            $output ~= self.format-success("All tests successful.\n");
        }

        if $aggregator.has-problems {
            $output ~= "\nTest Summary Report";
            $output ~= "\n-------------------\n";
            for $aggregator.results -> $result {
                my $name = $result.name;
                if $result.has-problems($!ignore-exit) {
                    my $spaces = ' ' x min($!longest - $name.chars, 1);
                    my $wait = $result.wait // '(none)';
                    my $line = "$name$spaces (Wstat: $wait Tests: {$result.tests-run} Failed: {$result.failed.elems})\n";
                    $output ~= self.format-failure($line);

                    if $result.failed -> @failed {
                        $output ~= self.format-failure('  Failed tests:  ' ~ @failed.join(' ') ~ "\n");
                    }
                    if $result.todo-passed -> @todo-passed {
                        $output ~= "  TODO passed:  { @todo-passed.join(' ') }\n";
                    }
                    if $result.wait -> $wait {
                        if $result.exit {
                            $output ~= self.format-failure("Non-zero exit status: { $result.exit }\n");
                        }
                        else {
                            $output ~= self.format-failure("Non-zero wait status: $wait\n");
                        }
                    }
                    if $result.errors -> @ ($head, *@tail) {
                        $output ~= self.format-failure("  Parse errors: $head\n");
                        $output ~= @tail.map({ self.format-failure(' ' x 16 ~ $_ ~ "\n") }).join('');
                    }
                }
            }
        }
        my $timing = $duration.defined ?? ",  { $duration.Int } wallclock secs" !! '';
        $output ~= "Files={ $aggregator.result-count }, Tests={ $aggregator.tests-run }$timing\n";
        my $status = $aggregator.get-status;
        $output ~= "Result: $status\n";
        $output;
    }
    method format-success(Str $output) {
        $output;
    }
    method format-failure(Str $output) {
        $output;
    }
    method format-return(Str $output) {
        $output;
    }
    method format-result(Session $session, TAP::Result $result) {
        my $output;
        my $name = $session.header;
        if ($result.skip-all) {
            $output = self.format-return("$name skipped\n");
        }
        elsif ($result.has-problems($!ignore-exit)) {
            $output = self.format-test-failure($name, $result);
        }
        else {
            my $time = self.timer && $result.time ?? sprintf ' %8d ms', Int($result.time * 1000) !! '';
            $output = self.format-return("$name ok$time\n");
        }
        $output;
    }
    method format-test-failure(Str $name, TAP::Result $result) {
        return if self.volume < Quiet;
        my $output = self.format-return("$name ");

        my $total = $result.tests-planned // $result.tests-run;
        my $failed = $result.failed + abs($total - $result.tests-run);

        if !$!ignore-exit && $result.exit -> $status {
            $output ~= self.format-failure("Dubious, test returned $status\n");
        }

        if $result.failed == 0 {
            $output ~= self.format-failure($total ?? "All $total subtests passed " !! 'No subtests run');
        }
        else {
            $output ~= self.format-failure("Failed {$result.failed.elems}/$total subtests ");
            if (!$total) {
                $output ~= self.format-failure("\nNo tests run!");
            }
        }

        if $result.skipped -> $skipped {
            my $passed = $result.passed - $skipped;
            my $test = 'subtest' ~ ( $skipped != 1 ?? 's' !! '' );
            $output ~= "\n\t(less $skipped skipped $test: $passed okay)";
        }

        if $result.todo-passed.elems -> $todo-passed {
            my $test = $todo-passed > 1 ?? 'tests' !! 'test';
            $output ~= "\n\t($todo-passed TODO $test unexpectedly succeeded)";
        }

        $output ~= "\n";
        $output;
    }
}
class Reporter::Text does Reporter {
    has IO::Handle $!handle;
    has Formatter::Text $!formatter;

    submethod BUILD(:@names, :$!handle = $*OUT, :$volume = Normal, :$timer = False, Bool :$ignore-exit) {
        $!formatter = Formatter::Text.new(:@names, :$volume, :$timer, :$ignore-exit);
    }

    method open-test(Str $name) {
        my $header = $!formatter.format-name($name);
        Reporter::Text::Session.new(:$name, :$header, :reporter(self));
    }
    method summarize(TAP::Aggregator $aggregator, Bool $interrupted, Duration $duration) {
        self!output($!formatter.format-summary($aggregator, $interrupted, $duration));
    }
    method !output(Any $value) {
        $!handle.print($value);
    }
    method print-result(Reporter::Text::Session $session, TAP::Result $report) {
        self!output($!formatter.format-result($session, $report));
    }
}

class Formatter::Console is Formatter::Text {
    my &colored = sub ($text, $) { $text }
    method format-success(Str $output) {
        colored($output, 'green');
    }
    method format-failure(Str $output) {
        colored($output, 'red');
    }
    method format-return(Str $output) {
        "\r$output";
    }
}

class Reporter::Console::Session does Session {
    has Int $!last-updated = 0;
    has Int $.plan = Int;
    has Int:D $.number = 0;
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
    method summary() {
        ($!number, $!plan // '?').join("/");
    }
}
class Reporter::Console does Reporter {
    has Formatter::Console $!formatter;
    has Int $!lastlength;
    has Supplier $events;
    has Reporter::Console::Session @!active;
    has Int $!tests;
    has Int $!fails;

    submethod BUILD(:@names, IO::Handle :$handle = $*OUT, :$volume = Normal, :$timer = False, Bool :$ignore-exit = False) {
        $!formatter = Formatter::Console.new(:@names, :$volume, :$timer, :$ignore-exit);
        $!lastlength = 0;
        $!events = Supplier.new;
        @!active .= new;
        $!tests = 0;

        my $now = 0;
        my $start = now;

        sub output-ruler(Bool $refresh) {
            my $new-now = now;
            return if $now == $new-now and !$refresh;
            $now = $new-now;
            return if $!formatter.volume < Quiet;
            my $header = sprintf '===( %7d;%d', $!tests, $now - $start;
            my @items = @!active.map(*.summary);
            my $ruler = ($header, |@items).join('  ') ~ ')===';
            $ruler = $ruler.substr(0,70) if $ruler.chars > 70;
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
        multi receive('summary', TAP::Aggregator $aggregator, Bool $interrupted, Duration $duration) {
            $handle.print($!formatter.format-summary($aggregator, $interrupted, $duration));
        }

        $!events.Supply.act(-> @args { receive(|@args) });
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
    method summarize(TAP::Aggregator $aggregator, Bool $interrupted, Duration $duration) {
        $!events.emit(['summary', $aggregator, $interrupted, $duration]);
    }

    method open-test(Str $name) {
        my $header = $!formatter.format-name($name);
        my $ret = Reporter::Console::Session.new(:$name, :$header, :reporter(self));
        @!active.push($ret);
        $ret;
    }
}

my class State does TAP::Entry::Handler {
    has Range $.allowed-versions = 12 .. 13;
    has Int $!tests-planned;
    has Int $!tests-run = 0;
    has Int $!passed = 0;
    has Int @!failed;
    has Str @!errors;
    has Int $!actual-passed = 0;
    has Int $!actual-failed = 0;
    has Int $!todo = 0;
    has Int @!todo-passed;
    has Int $!skipped = 0;
    has Int $!unknowns = 0;
    has Bool $!skip-all = False;

    has Promise $.bailout;
    has Int $!seen-lines = 0;
    enum Seen <Unseen Before After>;
    has Seen $!seen-plan = Unseen;
    has Promise $.done = Promise.new;
    has Int $!version;
    has Bool $.loose;

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
        if $test.is-ok {
            $!passed++;
        }
        else {
            @!failed.push($usable-number);
        }
        ($test.ok ?? $!actual-passed !! $!actual-failed)++;
        $!todo++ if $test.directive == TAP::Todo;
        @!todo-passed.push($usable-number) if $test.ok && $test.directive == TAP::Todo;
        $!skipped++ if $test.directive == TAP::Skip;

        if !$!loose && $test ~~ TAP::Sub-Test {
            for $test.inconsistencies(~$usable-number) -> $error {
                self!add-error($error);
            }
        }
    }
    multi method handle-entry(TAP::Bailout $entry) {
        if $!bailout.defined {
            $!bailout.break($entry);
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
        TAP::Result.new(:$name, :$!tests-planned, :$!tests-run, :$!passed, :@!failed, :@!errors, :$!skip-all,
            :$!actual-passed, :$!actual-failed, :$!todo, :@!todo-passed, :$!skipped, :$!unknowns, :$exit-status, :$time);
    }
    method !add-error(Str $error) {
        push @!errors, $error;
    }
}

my class Run {
    subset Killable of Any where { .can('kill') };
    has Supply:D $.events is required;
    has Promise:D $.process = $!events.Promise;
    has Killable $!killer;
    has Promise $!timer;

    method kill() {
        $!killer.kill if $!process;
    }
    method exit-status() {
        $!process.result ~~ Proc ?? $.process.result !! Proc;
    }
    method time() {
        $!timer.defined ?? $!timer.result !! Duration;
    }
}

role Source {
    has Str $.name;
}
class Source::Proc does Source {
    has Str $.path is required;
    has @.args;
    has $.err is required;
}
class Source::File does Source {
    has Str $.filename;
}
class Source::String does Source {
    has Str $.content;
}
class Source::Supply does Source {
    has Supply $.supply;
}

class Async {
    has Str $.name;
    has Run $!run handles <kill events>;
    has State $!state;
    has Promise $.waiter;

    submethod BUILD(Str :$!name, State :$!state, Run :$!run) {
        $!waiter = Promise.allof($!state.done, $!run.process);
    }

    multi get_runner(Source::Proc $proc) {
        my $async = Proc::Async.new($proc.path, $proc.args);
        my $events = parser($async.stdout);
        given $proc.err {
            my $err = $_;
            when 'stderr' { #default is correct
            }
            when 'merge' {
                warn "Merging isn't supported yet on Asynchronous streams";
                $async.bind-stderr(open($*SPEC.devnull, :w))
            }
            when 'ignore' {
                $async.bind-stderr(open($*SPEC.devnull, :w))
            }
            when IO::Handle:D {
                $async.stderr.lines(:close).act({ $err.say($_) });
            }
            when Supply:D {
                $async.stderr.act({ $err.emit($_) }, :done({ $err.done }), :quit({ $err.quit($^reason) }));
            }
            default {
                die "Unknown error handler";
            }
        }
        my $process = $async.start;
        my $start-time = now;
        my $timer = $process.then({ now - $start-time });
        Run.new(:$process, :killer($async), :$timer, :$events);
    }
    multi get_runner(Source::Supply $supply) {
        my $start-time = now;
        my $events = parser($supply.supply);
        Run.new(:$events);
    }
    multi get_runner(Source::File $file) {
        my $events = parser(supply { emit $file.filename.IO.slurp(:close) });
        Run.new(:$events);
    }
    multi get_runner(Source::String $string) {
        my $events = parser(supply { emit $string.content });
        Run.new(:$events);
    }

    method new(Source :$source, Promise :$bailout, Bool :$loose) {
        my $state = State.new(:$bailout, :$loose);
        my $run = get_runner($source);
        $state.listen($run.events);
        Async.bless(:name($source.name), :$state, :$run);
    }

    has TAP::Result $!result;
    method result {
        await $!waiter;
        $!result //= $!state.finalize($!name, $!run.exit-status, $!run.time);
    }
}

class Harness {
    role SourceHandler {
        method can-handle {...};
        method make-source {...};
    }
    role SourceHandler::Proc does SourceHandler {
        has Str:D $.path is required;
        has @.args;
        method make-source(Str:D $name, Any:D :$err) {
            TAP::Source::Proc.new(:$name, :$!path, :args[ |@!args, $name ], :$err);
        }
    }
    class SourceHandler::Perl6 does SourceHandler::Proc {
        submethod BUILD(:@incdirs, Str:D :$!path = $*EXECUTABLE.absolute) {
            @!args = @incdirs.map("-I" ~ *);
        }
        method can-handle(Str $name) {
            0.5;
        }
    }
    class SourceHandler::Exec does SourceHandler::Proc {
        method new (*@ ($path, *@args)) {
            self.bless(:$path, :@args);
        }
        method can-handle(Str $name) {
            1;
        }
    }

    has SourceHandler @.handlers = SourceHandler::Perl6.new();
    has IO::Handle $.handle = $*OUT;
    has Formatter::Volume $.volume = Normal;
    has TAP::Reporter:U $.reporter-class = $!handle.t && $!volume < Verbose ?? TAP::Reporter::Console !! TAP::Reporter::Text;
    has Int:D $.jobs = 1;
    has Bool:D $.timer = False;
    subset ErrValue where any(IO::Handle:D, Supply, 'stderr', 'ignore', 'merge');
    has ErrValue $.err = 'stderr';
    has Bool:D $.ignore-exit = False;
    has Bool:D $.trap = False;
    has Bool:D $.loose = $*PERL.compiler.version before 2017.09;

    class Run {
        has Promise $.waiter handles <result>;
        has Promise $!killed;
        submethod BUILD (Promise :$!waiter, Promise :$!killed) {
        }
        method kill(Any:D $reason) {
            $!killed.break($reason);
        }
    }

    method make-aggregator() {
        TAP::Aggregator.new(:$!ignore-exit);
    }
    method add-handlers(Supply $events) {
        if $.volume == Verbose {
            $events.act({ $!handle.say(~$^entry) }, :done({ $!handle.flush }), :quit({ $!handle.flush }));
        }
    }
    method make-source(Str $name) {
        @!handlers.max(*.can-handle($name)).make-source($name, :$!err);
    }
    my &sigint = sub { signal(SIGINT) }

    method run(*@sources) {
        my $killed = Promise.new;
        my $aggregator = self.make-aggregator;
        my $reporter = $!reporter-class.new(:names(@sources), :$!timer, :$!ignore-exit, :$!volume, :$!handle);

        my @working;
        my $waiter = start {
            my $int = $!trap ?? sigint().tap({ $killed.break("Interrupted"); $int.close(); }) !! Tap;
            my $begin = now;
            try {
                for @sources -> $name {
                    my $session = $reporter.open-test($name);
                    my $source = self.make-source($name);
                    my $parser = TAP::Async.new(:$source, :$killed, :$!loose);
                    $session.listen($parser.events);
                    self.add-handlers($parser.events);
                    @working.push({ :$parser, :$session, :done($parser.waiter) });
                    next if @working < $!jobs;
                    await Promise.anyof(@working»<done>, $killed);
                    reap-finished();
                }
                while @working {
                    await Promise.anyof(@working»<done>, $killed);
                    reap-finished();
                }
                CATCH {
                    when "Interrupted" {
                        reap-finished();
                        @working».<parser>».kill;
                    }
                }
            }
            $reporter.summarize($aggregator, ?$killed, now - $begin) if !$killed || $!trap;
            $int.close if $int;
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
        Run.new(:$waiter, :$killed);
    }
}
