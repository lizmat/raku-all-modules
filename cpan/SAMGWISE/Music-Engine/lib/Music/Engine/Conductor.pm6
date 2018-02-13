use v6;

unit class Music::Engine::Conductor;
use Music::Engine::Section::Context;
use Music::Engine::Section;
use ScaleVec::Scale;
use Net::OSC::Server;
use ScaleVec;

has Music::Engine::Section   $.section is required;
has Int               $.phrase = 8;
has Int               $!phrase-pos = -1;
has ScaleVec::Scale             $.pulse is required;
has ScaleVec::Scale             $.output-space is required;
has Net::OSC::Server  $.server;

has ScaleVec $!milli-seconds = ScaleVec.new( :vector(0, 1000, 2000) );

has &!send-note-closure; # is lazy
method build-send-note-closure( --> Sub) {
  return &!send-note-closure if &!send-note-closure.defined;
  my $self = self;
  &!send-note-closure = sub (Str $path, Int $note, Int $vel, Numeric $duration, Numeric(Cool) :$in = 0 --> Promise) {
    $self.send-note($path, $note, $vel, $duration, :$in);
  }
  &!send-note-closure
}

method send-note(Str $path, Int $note, Int $vel, Numeric $duration, Numeric(Cool) :$in = 0 --> Promise) {
  Promise.in($in).then( {
    $!server.send: "$path/note", :args($!output-space.step($note).Int, $vel, $!milli-seconds.step($duration).Int)
  } ).then( { sleep $duration } )
}


has Music::Engine::Section::Context $!section-context; # is sudo lazy, only updated in course of run loop
method build-context( --> Music::Engine::Section::Context) {
  return $!section-context if $!section-context.defined;
  Music::Engine::Section::Context.new(
    :phrase-step($!phrase-pos)
    :send-note(&!send-note-closure)
    :$!output-space
  );
}

method run() {
  $!section-context = $!section.setup(self.build-context);

  #timing
  my Supplier $metro .= new;
  start {
    my $current-time;
    my $next-time-step = now;
    for 1..∞ {
      for 1..$!phrase -> $pos {
        $current-time = $next-time-step;
        $next-time-step += $!pulse.interval($pos - 1, $pos);
        await Promise.at($next-time-step).then: {
          put "Tick";
          $metro.emit: $pos;
        }
      }
    }
  }

  # Run loop
  for 1..∞ {
    say '-' x 78;
    put "Updating...";
    $!section-context = $!section.update(self.build-context);

    put "Waiting...";
    my Promise $signal .= new;
    start {
      react {
        whenever $metro.Supply -> $pos {
          put "Recieved tick $pos";
          $!phrase-pos = $pos;
          $signal.keep;
          done;
        }
      }
    }

    await $signal;
    put "Playing";
    start {
      $!section-context = $!section.play(self.build-context)
    }
  }

}
