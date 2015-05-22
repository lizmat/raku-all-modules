use Event::Emitter::Role::Handler;
unit role Event::Emitter::Supply does Event::Emitter::Role::Handler;

has @!events;
has Supply $!supply;

submethod BUILD {
  $!supply := Supply.new;
  $!supply.tap(-> $msg {
    $_<callable>.($msg<data>) for @!events.grep(-> $e {
      given ($e<event>.WHAT) {
        when Regex { $msg<event> ~~ $e<event> }
        when Callable { $e<event>.($msg<event>); }
        default { $e<event> eq $msg<event> }
      };
    });
  });
}

method on($event, Callable $callable) {
  @!events.push({ 
    event => $event, 
    callable => $callable,
  });
}

method emit($event, $data? = Nil) {
  $!supply.emit({ event => $event, data => $data });
}
