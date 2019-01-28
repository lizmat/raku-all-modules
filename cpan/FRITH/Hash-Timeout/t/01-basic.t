#!/usr/bin/env perl6

use lib 'lib';
use Test;
use Hash::Timeout;

subtest {
  my %h1 does Hash::Timeout[3] = :1a, :2b, :3c;
  does-ok %h1, Hash::Timeout, 'does Hash::Timeout';
  is %h1.Str, "a\t1 b\t2 c\t3", '.Str works';
  is %h1.gist, '{a => 1, b => 2, c => 3}', '.gist works';
  ok %h1.keys ~~ <a b c>.Set, '.keys works';
  ok %h1.values ~~ (1, 2, 3).Set, '.values works';
  ok %h1.pairs ~~ (:1a, :2b, :3c).Set, '.pairs works';
  ok %h1.kv ~~ (1, 2, 3, 'a', 'b', 'c').Set, '.kv works';
  is %h1.perl, 'Hash+{Hash::Timeout[Int]}.new(:a(1),:b(2),:c(3))', '.perl works';
}, 'test basic methods after initialization';

subtest {
  my %h does Hash::Timeout[0.5];
  ok %h.timeout == 0.5, 'timeout method';
  lives-ok { %h<a> = 13 }, 'can assign a value';
  ok %h<a> == 13, 'can read a value';
  sleep 1;
  nok %h<a>:exists, 'value expires';
  %h<b> = 2;
  %h = Hash.new;
  sleep 1;
  ok %h.elems == 0, 'can delete a value before timeout';
  lives-ok { %h = 'a' => 1 }, 'can store pairs';
}, 'test timeout';

done-testing;
