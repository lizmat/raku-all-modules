use v6.c;
unit module PowerNap:ver<0.0.2>;

=begin pod

=head1 NAME

PowerNap - A short but strict REST service framework

=head1 SYNOPSIS

  use PowerNap;

=head1 DESCRIPTION

PowerNap is simple way to write strict and concise restful web APIs.

The core of PowerNap is the PowerNap::Controller.
This role provides a number of default methods and a verb dispatcher.
Given a `PowerNap::Verb` `Enum` and a `Map` the dispatcher routes to the relevant method and attempts to call the method with the given `Map`.
If there is a type mismatch or missing required pairs a 501 response will be returned, 500 if any other exception is thrown and the method controlls any other responses.

All returned values are classes which implement the `PowerNap::Result` role.
These result objects can be introspected as to their error code, if they are an error and impliment an `.ok(Str --> Map)` method to allow localised error messages in chained method calls.
All result objects implemt the `Serialise::Map` ([see](http://modules.perl6.org/dist/Serialise::Map:cpan:SAMGWISE)), as such calling `.to-map(--> Map).&to-json` will provide a serialised response.

When selecting response codes for your controller methods you should consider recent [HTTP RFCs](https://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html) or similar.

=head1 AUTHOR

 Sam Gillespie

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Sam Gillespie

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
#
# HTTP Verb types
#
enum Verb <GET POST PUT PATCH DELETE>;

#
# Results
#

use Serialise::Map;
role Result does Serialise::Map {
  has Int $.code;
  has Map $.payload;

  method ok(Str $msg) { ... }
  method is-ok( --> Bool) { ... }
  method is-err( --> Bool) { ... }

  method to-map( --> Map) { %(:$!code, :$!payload) }
  method from-map(Map $map --> Result) { self.new(|$map) }
}

class Result::Ok does Result {
  method ok(Str $msg) { $!payload }
  method is-ok( --> Bool) { True }
  method is-err( --> Bool) { False }
}

class Result::Err does Result {
  method ok(Str $msg) { die $!payload ~ "\n" ~ $msg }
  method is-ok( --> Bool) { False }
  method is-err( --> Bool) { True }
}

sub result-ok(Int $code, Map $payload --> Result::Ok) is export {
  PowerNap::Result::Ok.new: :$code, :$payload;
}

sub result-err(Int $code, Str $error --> Result::Err) is export {
  PowerNap::Result::Err.new: :$code, payload => %(:$error);
}
