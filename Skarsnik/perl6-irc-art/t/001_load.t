# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test;

BEGIN { use-ok 'IRC::Art' }

my IRC::Art $object .= new(5,5);
isa-ok $object, IRC::Art;


can-ok($object, 'pixel');
can-ok($object, 'rectangle');
can-ok($object, 'result');
can-ok($object, 'Str');
can-ok($object, 'text');
can-ok($object, 'load');
can-ok($object, 'save');

done-testing;

