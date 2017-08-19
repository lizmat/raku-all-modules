use Event::Emitter::Role::Handler;
unit role Event::Emitter::Channel does Event::Emitter::Role::Handler;

has @!events;
has Channel $!channel;
has $!promise;

submethod BUILD {
  $!channel := Channel.new;
  $!promise := start {
    loop {
      my $msg = $!channel.receive;
      CATCH { last when X::Channel::ReceiveOnClosed }
      $_<callable>.($msg<data>) for @!events.grep(-> $e {
        given ($e<event>.WHAT) {
          when Regex { $msg<event> ~~ $e<event> }
          when Callable { $e<event>.($msg<event>); }
          default { $e<event> eq $msg<event> }
        };
      });
    }
  };
  END {
    $!channel.close;
    await $!promise;
  };
}

method on($event, Callable $callable) {
  @!events.push({ 
    event => $event, 
    callable => $callable,
  });
}

method emit($event, $data? = Nil) {
  $!channel.send({ event => $event, data => $data });
}
