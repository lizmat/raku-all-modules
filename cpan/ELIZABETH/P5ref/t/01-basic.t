use v6.c;
use Test;
use P5ref;

plan 16;

ok defined(::('&ref')),       'is &ref imported?';
ok !defined(P5ref::{'&ref'}), 'is &ref externally NOT accessible?';

my @a;
my %h;
my $a = 42;

is ref(@a),     'ARRAY', 'did we get ARRAY';
is ref(%h),      'HASH', 'did we get HASH';
is ref({...}),   'CODE', 'did we get CODE';
is ref(v6.c), 'VSTRING', 'did we get VSTRING';
is ref(/foo/), 'Regexp', 'did we get Regexp';
is ref($a),    'SCALAR', 'did we get SCALAR';
is ref(42),       'Int', 'did we get Int';

with @a    { is ref,   'ARRAY', 'did we get ARRAY'   }
with %h    { is ref,    'HASH', 'did we get HASH'    }
with {...} { is ref,    'CODE', 'did we get CODE'    }
with v6.c  { is ref, 'VSTRING', 'did we get VSTRING' }
with /foo/ { is ref,  'Regexp', 'did we get Regexp'  }
with $a    { is ref,  'SCALAR', 'did we get SCALAR'  }
with 42    { is ref,     'Int', 'did we get Int'     }

# vim: ft=perl6 expandtab sw=4
