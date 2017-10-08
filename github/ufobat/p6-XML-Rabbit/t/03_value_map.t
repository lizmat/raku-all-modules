use v6.c;
use Test;
use XML::Rabbit;

plan 5;

class TestMe does XML::Rabbit::Node {
    has $.x is xpath('/xml/b/@key' => '/xml/b');
}

my $f = TestMe.new(file => 't/example.xml');

isa-ok $f.x, Hash, 'found a hash';
is $f.x.elems, 3, 'with 3 elements';
is $f.x<key-1>, 'a', 'a';
is $f.x<key-2>, 'simple', 'simple';
is $f.x<key-3>, 'list', 'list';

done-testing;

