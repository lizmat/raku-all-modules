use v6.c;
use Test;
use XML::Rabbit;

plan 2;

class TestMe does XML::Rabbit::Node {
    has $.x is xpath("/xml/a");
    has $.y is xpath('/doenst/exist');
}

my $f = TestMe.new(file => 't/example.xml');

is $f.x, 'example', 'fetching singular value';
is $f.y, (Any), 'fetching non existant value';

done-testing;

