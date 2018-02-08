use v6.c;

=begin pod

=head1 Serialise::Map

Serialise::Map - a composable interface for serialising objects

=head1 SYNOPSIS

  use Serialise::Map;
  use Test;

  class Foo does Serialise::Map {
    has $.value;

    to-map( --> Map) {
      %(
        :$!value
      )
    }

    from-map(Map $map --> Foo) {
      self.new(|$map)
    }
  }

  my $obj = Foo.new( :value('Bar') );

  # Test your implementations!
  is-deeply $obj.to-map, $obj.from-map($obj.to-map), "";

=head1 DESCRIPTION

Serialise::Map is a simple interface that specifies a simple contract.
I can give you a map, which represents my current state and consume a map to recreate my current state.
Although round trip safe behaviour is not guaranteed it is probably expected so it is recommended for your users to keep this in mind.


=head1 AUTHOR

Sam Gillespie <samgwise@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2017 Sam Gillespie

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

role Serialise::Map {
  method to-map( --> Map) { ... }

  method from-map(Map $map) { ... }
}
