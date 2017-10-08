use v6.c;
use Test;
use XML::Rabbit;

plan 5;

class TestMe does XML::Rabbit::Node {
    has $.x is xpath("/xml/b");
}

my $f = TestMe.new(file => 't/example.xml');

isa-ok $f.x, Array, 'found an array';
is $f.x.elems, 3, 'with 3 elements';
is $f.x[0], 'a', 'a';
is $f.x[1], 'simple', 'simple';
is $f.x[2], 'list', 'list';

done-testing;

