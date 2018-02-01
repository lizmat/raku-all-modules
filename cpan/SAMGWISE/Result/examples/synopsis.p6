#! /usr/bin/env perl6
use v6;
use Result;
use Result::Imports;

sub schrödinger-roulette(Str $cat-name --> Result) {
  given (0, 1).pick {
    when 0 {
      OK( "{ $cat-name.tc } is alive!", :type(Str) )
    }
    when 1 {
      Error( "{ $cat-name.tc } is no more." )
    }
  }
}

# managed errors
given schrödinger-roulette("Dutches") {
  when Result::OK {
    say .value
  }
  when Result::Err {
    say "Oh no! { .error } Let's give it another go...";
  }
}

# Unmanaged errors
schrödinger-roulette("O'Mally")
  .ok("Perhaps we shouldn't be playing this game...")
  .say;
