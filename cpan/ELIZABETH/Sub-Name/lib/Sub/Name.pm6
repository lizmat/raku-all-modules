use v6.c;
unit class Sub::Name:ver<0.0.1>;

# only export the proto
proto sub subname(|) is export {*}
# handle name, { ... } case
multi sub subname($name, &callable) { set-subname($name,     &callable)   }
# handle foo => { ... } case
multi sub subname(Pair:D $pair)     { set-subname($pair.key, $pair.value) }

# the workhorse
sub set-subname($name is copy, &callable) {
    &callable.set_name(
      $name.contains('::')
        ?? $name
        !! CALLER::CALLER::<::?PACKAGE>.^name ~ '::' ~ $name
    );
    &callable
}

=begin pod

=head1 NAME

Sub::Name - Port of Perl 5's Sub::Name

=head1 SYNOPSIS

  use Sub::Name;

  subname $name, $callable;

  $callable = subname foo => { ... };

=head1 DESCRIPTION

This module has only one function, which is also exported by default:

subname NAME, CALLABLE

Assigns a new name to referenced Callable. If package specification is omitted
in the name, then the current package is used. The return value is the Callable.

The name is only used for informative routines. You won't be able to actually
invoke the Callable by the given name. To allow that, you need to do assign it
to a &-sigilled variable yourself.

Note that for anonymous closures (Callables that reference lexicals declared
outside the Callable itself) you can name each instance of the closure
differently, which can be very useful for debugging.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Re-imagined from the Perl 5 version as part of the CPAN Butterfly Plan.
Perl 5 version originally developed by Matthijs van Duin.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
