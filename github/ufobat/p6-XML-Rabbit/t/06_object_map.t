use v6.c;
use Test;
use XML::Rabbit;

plan 8;

class TestMe does XML::Rabbit::Node {
    has $.x is xpath-object('TestB', '/xml/b/@key' => '/xml/b');
}

class TestB does XML::Rabbit::Node {
    has $.value is xpath('.');
    has $.key is xpath('./@key');
}

my $f = TestMe.new(file => 't/example.xml');


isa-ok $f.x, 'Hash', 'created a Hash object for /xml/b';
is $f.x.elems, 3, 'got 3 elements';

is $f.x<key-1>.value, 'a', 'value 1st';
is $f.x<key-1>.key, 'key-1', 'key 1st';

is $f.x<key-2>.value, 'simple', 'value 2nd';
is $f.x<key-2>.key, 'key-2', 'key 2nd';

is $f.x<key-3>.value, 'list', 'value 3rd';
is $f.x<key-3>.key, 'key-3', 'key 3rd';

done-testing;

