use v6;

class RunServer {

    use File::Which;

    has Int     $.port = 1234;
    has Str     $.script;
    has Str     $.liquidsoap;
    has Supply  $.stdout;
    has Supply  $.stderr;

    has Proc::Async $!proc;
    has Promise     $.Promise;

    class X::NoSoap is Exception {
        has $.message = "Can't find a 'liquidsoap' to run";
    }
    
    multi submethod BUILD(Int :$!port = 1234, Str :$!script, Str :$liquidsoap) {
        $!liquidsoap = %*ENV<LIQUIDSOAP> // $liquidsoap // which('liquidsoap');

        if not ( $!liquidsoap.defined && $!liquidsoap.IO.x ) {
            X::NoSoap.new.throw;
        }

        my $set-port = "set('server.telnet.port',{ $!port })";

        my @args = '--enable-telnet', '--force-start', '--verbose', $set-port, $!script // Empty;

        $!proc = Proc::Async.new($!liquidsoap, @args);
        $!stdout = $!proc.stdout;
        $!stderr = $!proc.stderr;
    }

    
    multi method run(RunServer:D:) {
        $!Promise = $!proc.start;
        my $s = self;
        my $t = signal(SIGHUP).tap({ $t.close; sleep 1; $s.kill });
        True;
    }

    multi method run(RunServer:U: |c) returns RunServer {
        my $runner = self.new(|c);
        $runner.run;
        $runner;
    }

    method kill() {
        if $!proc.defined {
            $!proc.kill('INT');
            True;
        }
        else {
            False;
        }
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
