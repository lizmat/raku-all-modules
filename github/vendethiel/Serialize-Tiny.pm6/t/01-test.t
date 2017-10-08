# TODO get a nicer filename...
use Test;
use Serialize::Tiny;

plan 2;

class A {
  has $.a;
  has $.b;
  has $!c;
};

my A $a .= new(:1a, :b('o rly'));
my %h = serialize($a);

is %h.keys, <a b>, 'It will filter out the keys without accessors';
is %h<a>, 1, 'It extracted the value correctly';
