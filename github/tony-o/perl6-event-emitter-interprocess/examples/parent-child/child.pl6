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
