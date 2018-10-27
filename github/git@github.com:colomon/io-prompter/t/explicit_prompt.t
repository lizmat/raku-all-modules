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
# OK have => prompt('Press "n"', :prompt("Press 'y'"), :yesno),
#    want => 1,
#    desc => "Override the prompt";

class StubIO is IO::Handle {
    has @.input handles (:push<push>, :get<shift>, :queue-input<push>);
    has @.output handles (:print<push>);
    multi method t() { Bool::True; }
}

my $stub = StubIO.new(:input("y"));

my $result = prompt('Press "n"', :prompt("Press 'y'"), :yesno, 
                    in => $stub,
                    out => $stub);
                    
OK have => $stub.output[0],
   want => "Press 'y' ", # not 100% sure this is the right prompt to be looking for --colomon
   desc => "Override the prompt";

