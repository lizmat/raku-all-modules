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
