use Event::Emitter::Role::Handler;
unit role Event::Emitter::Supply does Event::Emitter::Role::Handler;

has @!events;
has Supplier $!supplier;
has Supply $!supply;

submethod BUILD {
    $!supplier = Supplier.new;
    $!supply := $!supplier.Supply;
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
    $!supplier.emit({ event => $event, data => $data });
}
