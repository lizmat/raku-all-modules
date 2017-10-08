#! /Users/damian/bin/rakudo*
use v6;

use Testing;
use IO::Prompter;

# Following commented out section is what Damian had. Unfortunately,
# SKIP doesn't really work as is in testing -- I think it needs to
# be a macro to work.  My own, non-interactive version of the test
# follows. --colomon

# SKIP 'Interactive test only' if $*IN !~~ :t || $*OUT !~~ :t;
# 
# OK have => prompt(:wf, :yn, 'This should have wiped the screen. Did it?'),
#    desc => "Wipe first";
# 
# OK have => prompt(:wf, :yn, 'This should not have wiped the screen. Did it?'),
#    want => 0,
#    desc => "Wipe first";
# 
# OK have => prompt(:w, :yn, 'This should have wiped the screen. Did it?'),
#    desc => "Wipe first";'

class StubIO is IO::Handle {
    has @.input handles (:push<push>, :get<shift>, :queue-input<push>);
    has @.output is rw handles (:print<push>);
    multi method t() { Bool::True; }
}

{
    my $stub = StubIO.new(:input("yes", "no"));

    OK have => prompt(:wf, :yn, 'This should have wiped the screen. Did it?', 
                      in => $stub,
                      out => $stub),
       desc => "Ok result returned from first wipefirst attempt";

    OK have => +$stub.output.join.lines > 50,
       desc => "At least 50 output lines from second wipefirst attempt";
    $stub.output = ();

    OK have => prompt(:wf, :yn, 'This should not have wiped the screen. Did it?'   , 
                      in => $stub,
                      out => $stub),
       want => 0,
       desc => "False result returned from second wipefirst attempt";
      
    OK have => +$stub.output.join.lines < 2,
       desc => "Less than two output lines from second wipefirst attempt";
}

{
    my $stub = StubIO.new(:input("yes", "no"));

    OK have => prompt(:w, :yn, 'This should have wiped the screen. Did it?', 
                      in => $stub,
                      out => $stub),
       desc => "Ok result returned from first wipe attempt";

    OK have => +$stub.output.join.lines > 50,
       desc => "At least 50 output lines from wipe attempt";
    $stub.output = ();
}
