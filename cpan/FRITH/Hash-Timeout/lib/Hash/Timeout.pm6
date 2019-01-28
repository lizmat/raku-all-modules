#!/usr/bin/env perl6

use Hash::Agnostic;

role Hash::Timeout:ver<0.0.1>:auth<cpan:FRITH>[$timeout = 3600] does Hash::Agnostic
{
  has %!hash;
  has %!cancel;

  method AT-KEY($key) is raw {
    Proxy.new(
      FETCH => { %!hash{$key} },
      STORE => -> $, \v is raw { %!hash{$key} = v }
    );
  }
  method EXISTS-KEY($key) {
    %!hash.{$key}.DEFINITE
  }
  method ASSIGN-KEY(\key, \value) {
    .cancel with %!cancel{key};
    %!cancel{key} := $*SCHEDULER.cue({ %!hash{key}:delete }, :in($timeout));
    %!hash{key} = value;
  }
  method BIND-KEY(\key, \value) {
    .cancel with %!cancel{key};
    %!cancel{key} := $*SCHEDULER.cue({ %!hash{key}:delete }, :in($timeout));
    %!hash{key} := value;
  }
  method DELETE-KEY(\key) {
    .cancel with %!cancel{key};
    %!hash{key}:delete
  }
  method CLEAR() {
    for %!cancel.keys -> \k {
      .cancel with %!cancel{k}
    }
    %!hash = Hash.new;
    %!cancel = Hash.new;
  }
  multi method STORE(::?ROLE:D: \values, :$initialize) {
    self.CLEAR;
    given values.WHAT {
      when List { self!STOREL(values) }
      when Hash { self!STOREH(values) }
    }
    self;
  }
  method !STOREH(%hash --> Int:D) {
    for %hash.kv -> \k, \v {
      self.ASSIGN-KEY(k, v);
    }
  }
  method !STOREL(@values --> Int:D) {
    my $last := Mu;
    my int $found;

    for @values {
      if $_ ~~ Pair {
        self.ASSIGN-KEY(.key, .value);
        ++$found;
      } elsif $_ ~~ Failure {
        .throw
      } elsif !$last =:= Mu {
        self.ASSIGN-KEY($last, $_);
        ++$found;
        $last := Mu;
      } elsif $_ ~~ Map {
        $found += self!STOREL([.pairs])
      } else {
        $last := $_;
      }
    }
    $last =:= Mu
      ?? $found
      !! X::Hash::Store::OddNumber.new(:$found, :$last).throw
  }
  method keys { %!hash.keys }
  method iterator() { %!hash.pairs.iterator }
  method timeout { $timeout }
  method debug { %!hash.elems, %!cancel.elems }
}

=begin pod

=head1 NAME

Hash::Timeout - Role for hashes whose elements timeout and disappear

=head1 SYNOPSIS

  use Hash::Timeout;

  my %cookies does Hash::Timeout[0.5];
  %cookies<user001> = 'id';
  sleep 1;
  say %cookies.elems; # prints 0

=head1 DESCRIPTION

Hash::Timeout provides a C<role> that can be mixed with a C<Hash>.

There's just one optional parameter, the timeout, which accepts fractional seconds and defaults to 1 hour.

=head1 AUTHOR

Fernando Santagata <nando.santagata@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Fernando Santagata

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
