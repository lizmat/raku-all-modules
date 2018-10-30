#!/usr/bin/env perl6

use lib 'lib';
use Event::Emitter;
use Test;

plan 5;

my $e = Event::Emitter.new(:threaded);

ok $e.class eq 'Event::Emitter::Channel', 'Event::Emitter(:threaded) uses Event::Emitter::Channel';

$e.on(/^^ "match regex event"/, -> $data { 
  ok $data<hashkey> eq 'hashvalue', '[Regex] Ensure we got the right data from the supply';
});

$e.on('match string', -> $data {
  ok $data<string> eq 'stringvalue', '[Str] Ensure we got the right data from the supply';
});

$e.on({ True; }, -> $data {
  ok $data<hashkey> eq 'hashvalue', '[Callable] Ensure we got data from Regex' if $data<hashkey>:exists;
  ok $data<string> eq 'stringvalue', '[Callable] Ensure we got data from Str' if $data<string>:exists;
});

$e.emit('match regex event', { hashkey => 'hashvalue' });
$e.emit('match string', { 'string' => 'stringvalue' });

#same syntax works regardless of backend
