#!/usr/bin/env perl6

use v6;

unit module Propius::Linked;

class Node {
  has $.value is required;
  has $!next = Nil;
  has $!prev = Nil;

  method !next() is rw {
    $!next;
  }

  method next() {
    $!next;
  }

  method !prev() is rw {
    $!prev;
  }

  method prev() {
    $!prev;
  }

  method put-after(Node:D $that) {
    $!next = $that!next;
    $that!next = self;
    $!next!prev = self;
    $!prev = $that;
  }

  method remove() {
    $!prev!next = $!next with $!prev;
    $!next!prev = $!prev with $!next;
    ($!next, $!prev) = Nil, Nil;
  }

  method together(Node:D :$prev, Node:D :$next) {
    $prev!next = $next;
    $next!prev = $prev;
  }
}

class Chain {
  has Node $!head;
  has Node $!tail;

  submethod BUILD() {
    $!head = Node.new: :value(Nil);
    $!tail = Node.new: :value(Nil);
    Node.together: prev => $!head, next => $!tail;
  }

  method move-to-head(Node:D $node) {
    $node.remove();
    $node.put-after($!head);
  }

  method is-empty() {
    $!head.next === $!tail;
  }

  method first() {
    $!head.next;
  }

  method last() {
    $!tail.prev;
  }

  method list() {
    my @result;
    my Node $pointer = $!head.next;
    while $pointer.value !=== Any {
      push @result, $pointer.value;
      $pointer .= next;
    }
    @result;
  }

  method back-list() {
    my @result;
    my Node $pointer = $!tail.prev;
    while $pointer.value !=== Any {
      push @result, $pointer.value;
      $pointer .= prev;
    }
    @result;
  }
}