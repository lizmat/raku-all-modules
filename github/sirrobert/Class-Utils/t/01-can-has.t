use v6;
use Test;
plan 2;

use Class::Utils;

class Breaks is Array {
  has $.foo = 'bar';
}

class Works is Array does Has {
  has $.foo = 'bar';
}

ok (!defined Breaks.new.foo), 'breaks breaks';
ok (Works.new.foo eq 'bar'), 'works works';


