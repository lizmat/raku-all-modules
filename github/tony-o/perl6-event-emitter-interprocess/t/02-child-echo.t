#!/usr/bin/env perl6

use Event::Emitter::Inter-Process;
use Test;

plan 2;

my $ee = Event::Emitter::Inter-Process.new;

my Proc::Async $proc .= new(:w, 'perl6', '-Ilib', $*SPEC.catpath('', 't', 'child-echo.pl6'));

$proc.stdout(:bin).act(-> $d {
  say '$PROC.stdout: ' ~ $d.decode; 
});

$proc.stderr(:bin).act(-> $d {
  say '$PROC.stderr: ' ~ $d.decode; 
});

$ee.hook($proc);

my $str1 = ('a'..'z').roll(64).join('');
my $str2 = ('A'..'Z').roll(512).join('');

my @events;
my $promise = Promise.new;
$ee.on("echo", -> $data {
  say 'echo: ' ~ $data.decode;
  @events.push($data.decode);
  $promise.keep(True);
});

my $pro = $proc.start;
sleep 2;
$ee.emit('echo'.encode, $str1.encode);
$ee.emit('echo'.encode, $str2.encode);

await Promise.allof($promise, $pro);

ok @events[0] eq $str1, "Did child echo '$str1'?";
ok @events[1] eq $str2, "Did child echo '$str2'?";
