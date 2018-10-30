#!/usr/bin/env perl6

use lib 'lib';
use Event::Emitter::Role::Template;
use Test;

plan 1;

my $dt = DateTime.new(now);
class Inherit does Event::Emitter::Role::Template {
  submethod TWEAK {
    $!event-emitter.on('time', -> $time {
      ok $time ~~ $dt, "check that the $time is a DateTime object (expected: {$dt.Str}, got: {$time.Str})";
    });
  }
}

my $i = Inherit.new;

$i.emit('time', $dt);
