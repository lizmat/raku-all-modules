use v6;
unit module JSON::Hjson;

use JSON::Hjson::Actions;
use JSON::Hjson::Grammar;

class X::JSON::Hjson::Invalid is Exception {
    has $.source;
    method message { "Input ($.source.chars() characters) is not a valid JSON string" }
}

sub from-hjson($text) is export {
    my $a = JSON::Hjson::Actions.new();
    my $o = JSON::Hjson::Grammar.parse($text, :actions($a));
    unless $o {
        X::JSON::Hjson::Invalid.new(source => $text).throw;
    }
    return $o.made;
}

=begin pod

=head1 NAME

JSON::Hjson - Human JSON (Hjson) deserializer

=head1 SYNOPSIS

  use JSON::Hjson;

  my $text = q:to'...';
  {
    // specify delay in
    // seconds
    delay: 1
    message: wake up!
  }
  ...
  say from-hjson($text).perl;

=head1 DESCRIPTION

JSON::Hjson implements Human JSON (Hjson) in Perl6 grammar.

=head1 SEE ALSO

L<JSON::Tiny>

L<https://hjson.org/rfc.html>

=head1 AUTHOR

Takumi Akiyama <t.akiym@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2016 Takumi Akiyama

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
