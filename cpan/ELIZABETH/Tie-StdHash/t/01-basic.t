use v6.c;
use Test;

use P5tie;
use Tie::StdHash;

plan 8;

my $object = tie my %h, Tie::StdHash;
isa-ok $object, Tie::StdHash, "is the object a Tie::StdHash?";
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
