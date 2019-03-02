use v6;

unit class Smack::Test::Smackup;

use Smack::Client;

# TODO Replace when IO has the ability to let IO assign the port and tell us
# which port was assigned.
constant $BASE-PORT = 46382;
my $port-iteration = 0;

has Bool $.quiet = ?%*ENV<TEST_SMACK_QUIET> // True;
has $.app is required;
has $.port = $BASE-PORT + $port-iteration++;
has $.skip-process-wait = %*ENV<TEST_SMACK_SKIP_PROCESS_WAIT>;
has @.tests;
has @.cmd = 'bin/smackup', '-a=t/apps/{app}', '-o=localhost', '-p={port}';
has $.startup-timeout = 10;
has $.test-timeout = 60;
has $.quit-timeout = 10;

has $.err = '';
has $!client = Smack::Client.new;
has $!server;
has $!promise;

method !resolve-cmd() {
    my %vars = :$.app, :$.port;
    .=subst(/'{' (<[ a .. z ]>+) '}'/, { %vars{$0} }, :g) for @!cmd;
}

method prepare-server() {
    self!resolve-cmd;
    note "# Running: $*EXECUTABLE -Ilib {@.cmd.join(' ')}";
    $!server = Proc::Async.new($*EXECUTABLE, '-Ilib', |@.cmd);
}

method run() {
    self.prepare-server;

    my $startup-timer = Promise.in($!startup-timeout);
    my $test-timer = Promise.in($!test-timeout);
    my $ready = Promise.new;
    my $finished = Promise.new;

    my $start-time = now;

    # Make sure we kill the server at the end, regardless of how we quit
    LEAVE { self.stop }

    react {
        whenever $!server.stderr -> $v {
            $!err ~= $v;
            self.diag($v);
        }
        whenever $!server.stdout.lines -> $v {
            my $started = ?($v ~~ /^ Starting >>/);
            if $started && !$ready {
                $ready.keep(now - $start-time);
            }
            self.diag($v);
        }
        whenever $startup-timer {
            die "test server startup took too long (more than $!startup-timeout seconds)" if !$ready;
        }
        whenever $test-timer {
            die "test server took too long running tests (more than $!test-timeout seconds)";
        }
        whenever $ready -> $startup-time {
            self.diag("Server took $startup-time seconds to start.");
            # Run test jobs asynchronously on their own threads
            my $tests = @.tests.Supply.start(-> &test {
                test($!client, "http://localhost:$.port/");
            }).migrate;

            # wait for all tests to complete
            whenever $tests {
                LAST $finished.keep(now - $start-time);
            }
        }
        whenever $finished -> $finish-time {
            self.diag("Server took $finish-time seconds to run tests.");

            self.stop;
        }
        whenever $!server.start {
            die "server quit during startup!\n\n$!err" unless $ready;
            die "server quit early!\n\n$!err" unless $finished;
            done;
        }
    }
}

method stop() {
    self.diag("Sending QUIT to server.");

    $!server.kill(Signal::SIGQUIT);

    Promise.in($!quit-timeout).then: {
        self.diag("Sending KILL to server.");
        $!server.kill(Signal::SIGKILL);
    };
}

method treat-err-as-tap() {
    use Test;
    subtest {
        my $i = 1;
        my $plan = 0;

        for $.err.lines {

            # Parse expected "TAP"
            when /^
                \s*
                $<ok> = [ "not "? "ok" ]
                " $i" >>
                [ \s* "#" \s* $<msg> = [ .* ] ]
            / {
                if $<ok> eq 'ok' {
                    pass($<msg>);
                }
                else {
                    flunk($<msg>);
                }
                $i++;
            }

            # Parse unexpected "TAP"
            when /^
                \s*
                $<ok> = [ "not "? "ok" ] " "
                $<got> = [ \d+ ] >>
                [ \s* "#" \s* $<msg> = [ .* ] ]
            / {
                flunk("out of order TAP output from p6w.errors");
                diag("\texpected: ok $i\n\t     got: $<ok> $<got>");
                is $<ok>, 'ok', $<msg>;
                $i++;
            }

            # Parse "TAP" test plan
            when /^ "1.." $<end-test> = [ \d+ ] $/ {
                $plan = $<end-test>.Int;
            }

            when /^ \s* "#" / { #`{ ignore comments } }

            when /^ \s* $/    { #`{ ignore blanks } }

            # Warn on other stuff
            default {
                note qq[# Strange "TAP" output from p6w.errors: $_];
            }
        }

        if $plan {
            plan $plan;
        }
        else {
            flunk(qq[no plan in "TAP" from p6w.errors]);
        }
    }, 'treat-err-as-tap';
}

method diag(*@msg, :$loud = False) {
    return if !$loud && $!quiet;
    my $msg = [~] @msg;
    note (("#" xx $msg.lines.elems) Z $msg.lines).join("\n");
}
