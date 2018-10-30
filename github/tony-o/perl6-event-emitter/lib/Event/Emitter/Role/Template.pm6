use Event::Emitter;

role Event::Emitter::Role::Template {
  has $!event-emitter = Event::Emitter.new;
  method on(*@_)   { $!event-emitter.on(|@_);   }
  method emit(*@_) { $!event-emitter.emit(|@_); }
}
