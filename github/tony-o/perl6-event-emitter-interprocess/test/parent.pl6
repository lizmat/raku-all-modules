use Event::Emitter::Inter-Process;

my $event = Event::Emitter::Inter-Process.new;

my Proc::Async $child .=new(:w, 'perl6', '-I../lib', 'child.pl6');

$event.hook($child);

$event.on('echo', -> $data {
  # got $data from child;
  say $data.decode;
});

$child.start;
sleep 1;


$event.emit('echo'.encode, 'hello'.encode);
$event.emit('echo'.encode, 'world'.encode);

sleep 4;

