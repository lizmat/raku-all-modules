use v6.c;

module Attribute::Predicate:ver<0.0.1>:auth<cpan:ELIZABETH> {
    multi sub trait_mod:<is>(Attribute:D \attr, :$predicate!) is export {
        if $predicate {
            my $name := $predicate ~~ Bool
              ?? "has-{attr.name.substr(2)}"
              !! $predicate.Str;
            my $method := method { attr.get_value(self).defined }
            $method.set_name($name);
            attr.package.^add_method($name,$method)
        }
    }
}

=begin pod

=head1 NAME

Attribute::Predicate - add "is predicate" trait to Attributes

=head1 SYNOPSIS

  use Attribute::Predicate;

  class Foo {
      has $.bar is predicate;         # adds method "has-bar"
      has $.baz is predicate<bazzy>;  # adds method "bazzy"
  }

  Foo.new(bar => 42).has-bar;    # True
  Foo.new(bar => 42).bazzy;      # False

=head1 DESCRIPTION

This module adds a C<is predicate> trait to C<Attributes>.  It is similar
in function to the "predicate" option of Perl 5's C<Moo> and C<Moose> object
systems.

If specified without any additional information, it will create a method
with the name "has-{attribute.name}".  If a specific string is specified,
then it will create the method with that given name.

The method in question will return a C<Bool> indicating whether the attribute
has a defined value.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/Attribute-Predicate .
Comments and Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: ft=perl6 expandtab sw=4
