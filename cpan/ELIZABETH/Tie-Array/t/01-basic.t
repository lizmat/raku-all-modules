use v6.c;
use Test;

use P5tie;
use Tie::Array;

plan 17;

my $object = tie my @a, Tie::Array;
isa-ok $object, Tie::Array, "is the object a Tie::Array?";
is @a[0], Any, 'did we get Any';

@a[0] = 666;
is @a[0], 666, 'did we get 666';

++@a[0];
is @a[0], 667, 'did we get 667';

is @a.push(42), "667 42", 'did push return ok';
is @a[1], 42, 'did we get 42';

is @a.shift, 667, 'did shift return ok';
is @a[0], 42, 'did we get 42';

is @a.pop, 42, 'did pop return ok';
is ?@a, False, 'does the array return False now';
is +@a, 0, 'do we have the right number of elems';

is @a.unshift(92), 92, 'did unshift return ok';
is @a[0], 92, 'did we get 92';
is ?@a, True, 'does the array return True now';
is @a.elems, 1, 'do we have the right number of elems';

is (@a = (1,2,3)), "1 2 3", 'did initialization with list go ok';
is @a, "1 2 3", 'did @a get initialized ok'

# vim: ft=perl6 expandtab sw=4
