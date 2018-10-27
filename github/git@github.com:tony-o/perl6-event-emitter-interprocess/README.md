# Event::Emitter::Inter-Process

An extension to `Event::Emitter` that will allow you to communicate efficiently between processes.

## Syntax

This module assumes you are familiar with (`Event::Emitter`)[https://github.com/tony-o/perl6-event-emitter]


#### Parent process

```perl6
use Event::Emitter::Inter-Process;

my $event = Event::Emitter::Inter-Process.new;

my Proc::Async $child .=new(:w, 'perl6', '-Ilib', 'child.pl6');

$event.hook($child);

$event.on('echo', -> $data {
  # got $data from child;
  say $data.decode;
});

$child.start;
sleep 1;


$event.emit('echo'.encode, 'hello'.encode);
$event.emit('echo'.encode, 'world'.encode);

sleep 2;

```

#### Child process

```perl6
use Event::Emitter::Inter-Process;

my $event = Event::Emitter::Inter-Process.new(:sub-process);

$event.on('echo', -> $data {
  "child echo: {$data.decode}".say;
  $event.emit('echo'.encode, $data);
});

sleep 3;
```

##### Parent output:

```
hello
world
```

##### Child output:

```
child echo: hello
child echo: world
```

# License

Free for all.
