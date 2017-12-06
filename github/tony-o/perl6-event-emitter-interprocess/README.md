# InterProcess Emitter

Perl6, now with interprocess `Supply` like functionality

## Usage

### parent.pl6

```perl6
use lib '../../lib';
use Event::Emitter::Inter-Process;

my Event::Emitter::Inter-Process $handler .=new;

my Proc::Async $proc .= new(:w, 'perl6', '-Ilib', 'child.pl6');

$handler.hook($proc);

my Promise $kill-after-first .=new;
$handler.on('echo', -> $data {
  say $data.decode; #do something with data
  $kill-after-first.keep;
});

$proc.start;

say 'parent:echo: "Hello world!"';
$handler.emit('echo'.encode, 'Hello world!'.encode);

await $kill-after-first;
```

### child.pl6

```perl6
use lib '../../lib';
use Event::Emitter::Inter-Process;

my Event::Emitter::Inter-Process $handler .=new(:sub-process);

my Promise $killer .=new;
$handler.on('echo', -> $d {
  say ' child:echo: "'~$d.decode~'"';
  $handler.emit('echo'.encode, $d);
  $killer.keep;
});

await $killer;
```


### hashtag results

```
parent:echo: "Hello world!"
 child:echo: "Hello world!"
Hello world!
```

## other uses

Your main perl6 process doesn't need to be the boss of your processes, EG your parent process doesn't *need* to start the child, they can run separately so long as the format (found in the pm6) is followed for stdout/stderr by the child.


