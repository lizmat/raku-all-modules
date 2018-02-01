use v6.c;

=begin pod

=head1 Result

Result - Functional error handling ala Rust.

=head1 SYNOPSIS

use Result;
use Result::Imports;

sub schrödinger-roulette(Str $cat-name --> Result) {
  given (0, 1).pick {
    when 0 {
      OK "{ $cat-name.tc } is alive!", :type(Str)
    }
    when 1 {
      Error( "{ $cat-name.tc } is no more." )
    }
  }
}

# dispatching errors without throwing
given schrödinger-roulette("Dutches") {
  when Result::OK {
    say .value
  }
  when Result::Err {
    say "Oh no! { .error } Let's give it another go...";
  }
}

# throw on errors
schrödinger-roulette("O'Mally")
  .ok("Perhaps we shouldn't be playing this game...")
  .say;


=head1 DESCRIPTION

Result is inspired by Rust's Result enum.
It provides an error management framework similar to Perl6's Failures, but with stricter semantics.
This is by no means a one to one port, but it does attempt to provide the core essentials of this pattern.

With the Result patttern, all values returned from a function are a Result type, either an OK or an Err.
To obtain the value returned by the function you can choose to dispatch the error yourself or call the ok(Str) method.
The ok(Str) method simply returns the value if it is called on a Result::OK object.
However if it is called on a Result::Err object the error will be thrown.
The message passed via ok(Str) method and the message from the Result::Err will be included in the Exception, providing both function and call specific error messages.

The value of a Result::OK message may have a type check applied to it.
If there is a violation of the constraint an exception will be thrown.

=head1 AUTHOR

Sam Gillespie <samgwise@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2017 Sam Gillespie

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

role Result {
  has Bool $!is-okeyed = False; #Has OK been called yet?

  method ok(Str $err-msg) { ... }

  method is-ok( --> Bool) { ... }

  method is-err(--> Bool) { ... }

}
