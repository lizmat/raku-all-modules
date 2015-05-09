role Event::Emitter::Role::Handler;

method emit($event, $data) { ... }
method on($event, Callable $callable) { ... };
