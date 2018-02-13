#! /usr/bin/env perl6
use v6;
use Test;

plan 6;

use Music::Engine::Section;
class Testing does Music::Engine::Section {
  has Promise $.setup-ok  = Promise.new;
  has Promise $.update-ok = Promise.new;
  has Promise $.play-ok   = Promise.new;

  # Optional
  method setup(Music::Engine::Section::Context $context --> Music::Engine::Section::Context) {
    # Was setup called
    $!setup-ok.keep(True);
    $context
  }

  # Required
  method update(Music::Engine::Section::Context $context --> Music::Engine::Section::Context) {
    # Was update called
    $!update-ok.keep(True);
    $context
  }

  method play(Music::Engine::Section::Context $context --> Music::Engine::Section::Context) {
    # Was play called
    $!play-ok.keep(True);
    $context
  }
}

use-ok 'Music::Engine::Conductor';
use Music::Engine::Conductor;

#pre object setup
my Testing $test .= new;
is $test.so, True, "Instantiate test Music::Engine::Section";

use ScaleVec;
my ScaleVec $pulse .= new( :vector(0, 2, 3, 5, 7, 8) );
my ScaleVec $chromatic = ScaleVec.new( :vector(48..60) );

use Net::OSC::Server::UDP;
my Net::OSC::Server::UDP $server .= new(
  :listening-address<0.0.0.0>
  :listening-port(33445)
  :send-to-address<127.0.0.1>   # ← Optional but makes sending to a single host very easy!
  :send-to-port(5634)               # ↲
);

# Create object
my Music::Engine::Conductor $conductor .= new(
  :$server
  :section($test)
  :$pulse
  :output-space($chromatic)
);

is $conductor.so, True, "Instantiate Music::Engine::Conductor";

await Promise.anyof(
  Promise.start({
    $conductor.run();
    CATCH { warn "{ .Str }\n{ .trace }" }
  }),
  Promise.allof($test.setup-ok, $test.update-ok, $test.play-ok),
  Promise.in(5).then({ fail "Test timed out!"; exit 1 })
);

is $test.setup-ok.result, True, "Setup executed";
is $test.update-ok.result, True, "Update executed";
is $test.play-ok.result, True, "Play executed";

#done-testing
