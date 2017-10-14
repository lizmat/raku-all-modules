#!/usr/bin/env perl6

use v6;
use Test;
use lib 'lib';
use Propius::Linked;

plan 13;

{
  my Propius::Linked::Chain $chain .= new;
  ok $chain.is-empty, 'new chain is empty';

  $chain.move-to-head: Propius::Linked::Node.new: value => 'a';
  is $chain.list, <a>, 'add new node to head';
  is $chain.back-list, <a>, 'back list with single element';

  my $second = Propius::Linked::Node.new: value => 'b';
  $chain.move-to-head: $second;
  is $chain.list, <b a>, 'add second node to head';
  is $chain.back-list, <a b>, 'back list with two elements';

  $second.remove();
  is $chain.list, <a>, 'list with single element after remove second';
  is $chain.back-list, <a>, 'back list with single element after remove second';
}

{
  my Propius::Linked::Chain $chain .= new;
  for <c b a> -> $value { $chain.move-to-head: Propius::Linked::Node.new: :$value }
  is $chain.list, <a b c>, 'list with three';
  is $chain.back-list, <c b a>, 'back list with three';

  $chain.move-to-head($chain.first.next);
  is $chain.list, <b a c>, 'list with three after move middle from first';
  is $chain.back-list, <c a b>, 'back list with three after move middle from first';

  $chain.move-to-head($chain.last.prev);
  is $chain.list, <a b c>, 'list with three after move middle from last';
  is $chain.back-list, <c b a>, 'back list with three after move middle from last';
}

done-testing;