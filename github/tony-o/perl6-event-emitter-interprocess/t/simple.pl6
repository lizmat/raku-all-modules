#!/usr/bin/env perl6

use Event::Emitter::Inter-Process;

my $ee = Event::Emitter::Inter-Process.new(:sub-process(True));

$ee.emit('hello'.encode, 'world 1'.encode);

$ee.emit('hello'.encode, 'world 2'.encode);

