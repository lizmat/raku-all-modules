use v6.c;
use Test;

use P5tie;
use Tie::Hash;

plan 8;

class Foo is Tie::Hash {
    has %.tied;
    has $!iterator;

    method TIEHASH() { self.new }
    method FETCH($k)             is raw { %!tied.AT-KEY($k)           }
    method STORE($k,\value)      is raw { %!tied.ASSIGN-KEY($k,value) }
    method EXISTS($k --> Bool:D)        { %!tied.EXISTS-KEY($k)       }
    method DELETE($k)            is raw { %!tied.DELETE-KEY($k)       }
    method FIRSTKEY() {
        $!iterator := %!tied.keys.iterator;
        (my $key := $!iterator.pull-one) =:= IterationEnd ?? Nil !! $key
    }
    method NEXTKEY(Mu $) {
        (my $key := $!iterator.pull-one) =:= IterationEnd ?? Nil !! $key
    }
    method SCALAR()  { %!tied.elems }
}

my $object = tie my %h, Foo;
isa-ok $object, Foo, "is the object a Foo?";
is %h<a>, Any, 'did we get Any';

%h<a> = 666;
is %h<a>, 666, 'did we get 666';

++%h<a>;
is %h<a>, 667, 'did we get 667';

is ?%h, True, 'does the array return True now';
is %h.elems, 1, 'do we have the right number of elems';

is (%h = "a",42,"b",666),
  "a\t42\nb\t666" | "b\t666\na\t42",     # order is undetermined, so test both
  'did initialization with list go ok';
is %h,
  "a\t42\nb\t666" | "b\t666\na\t42",     # order is undetermined, so test both
  'did %h get initialized ok'

# vim: ft=perl6 expandtab sw=4
