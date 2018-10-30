use Event::Emitter::Inter-Process;

my $event = Event::Emitter::Inter-Process.new(:sub-process);

$event.on('echo', -> $data {
  "child echo: {$data.decode}".say;
  $event.emit('echo'.encode, $data);
});

sleep 3;
