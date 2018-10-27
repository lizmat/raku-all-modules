use Event::Emitter::Role::Handler;


class Event::Emitter {
  has $.class is readonly;

  submethod BUILD(Bool :$threaded? = False, Str :$class? is copy = 'Event::Emitter::Supply') {
    $class = 'Event::Emitter::Channel' if $threaded && $class eq 'Event::Emitter::Supply';
    require ::($class);
    die "$class does not do Event::Emitter::Role::Handler" if ::($class) !~~ Event::Emitter::Role::Handler;
    self does ::($class);
    $!class := $class;
  };

}

