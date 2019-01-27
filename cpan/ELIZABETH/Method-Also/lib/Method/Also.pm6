use v6.c;

module Method::Also:ver<0.0.1>:auth<cpan:ELIZABETH> {
    multi sub trait_mod:<is>(Method:D \meth, :$also!) is export {
        if $also {
            if $also ~~ List {
                meth.package.^add_method($_,meth) for @$also;
            }
            else {
                meth.package.^add_method($also.Str,meth);
            }
        }
    }
}

=begin pod

=head1 NAME

Method::Also - add "is also" trait to Methods

=head1 SYNOPSIS

  use Method::Also;

  class Foo {
      has $.foo;
      method foo() is also<bar bazzy> { $!foo }
  }

  Foo.new(foo => 42).bar;       # 42
  Foo.new(foo => 42).bazzy;     # 42

  # separate multi methods can have different aliases
  class Bar {
      multi method foo()     is also<bar>   { 42 }
      multi method foo($foo) is also<bazzy> { $foo }
  }

  Bar.foo;        # 42
  Bar.foo(666);   # 666
  Bar.bar;        # 42
  Bar.bazzy(768); # 768

=head1 DESCRIPTION

This module adds a C<is also> trait to C<Method>s, allowing you to specify
other names for the same method.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/Method-Also .
Comments and Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: ft=perl6 expandtab sw=4
