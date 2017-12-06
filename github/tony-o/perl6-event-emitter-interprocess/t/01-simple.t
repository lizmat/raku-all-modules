#!/usr/bin/env perl6

use Event::Emitter::Inter-Process;
use Test;

plan 2;

my $ee = Event::Emitter::Inter-Process.new;

#one way, parent -> child
my Proc::Async $proc .= new('perl6', '-Ilib', $*SPEC.catpath('', 't', 'simple.pl6'));

$ee.hook($proc);

my @events;
my $promise = Promise.new;

$ee.on("hello", -> $data {
  @events.push($data.decode);
  $promise.keep(True) if @events.elems == 2;
});

$proc.start;
await $promise;

try $proc.kill;

ok @events[0] eq 'world 1', 'first fire is world 1';
ok @events[1] eq 'world 2', 'second fire is world 2';
