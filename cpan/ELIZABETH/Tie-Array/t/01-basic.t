use v6.c;
use Test;

use P5tie;
use Tie::Array;

plan 17;

class Foo is Tie::Array {
    has @!tied;

    method TIEARRAY() { self.new }

    method FETCH($i)      is raw { @!tied.AT-POS($i)         }
    method STORE($i,\val) is raw { @!tied.ASSIGN-POS($i,val) }
    method FETCHSIZE()           { @!tied.elems              }
    method STORESIZE(\size) {
        my \elems = @!tied.elems;
        if size > elems {
            @!tied.ASSIGN-POS( size - 1, Nil )
        }
        elsif size < elems {
            @!tied.splice(size);
        }
    }
}

my $object = tie my @a, Foo;
isa-ok $object, Foo, "is the object a Foo?";
is @a[0], Any, 'did we get Any';

@a[0] = 666;
is @a[0], 666, 'did we get 666';

++@a[0];
is @a[0], 667, 'did we get 667';

is @a.push(42), 2, 'did push return ok';
is @a[1], 42, 'did we get 42';

is @a.shift, 667, 'did shift return ok';
is @a[0], 42, 'did we get 42';

is @a.pop, 42, 'did pop return ok';
is ?@a, False, 'does the array return False now';
is +@a, 0, 'do we have the right number of elems';

is @a.unshift(92), 1, 'did unshift return ok';
is @a[0], 92, 'did we get 92';
is ?@a, True, 'does the array return True now';
is @a.elems, 1, 'do we have the right number of elems';

is (@a = (1,2,3)), "1 2 3", 'did initialization with list go ok';
is @a, "1 2 3", 'did @a get initialized ok'

# vim: ft=perl6 expandtab sw=4
