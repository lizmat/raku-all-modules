use v6.c;
use Test;
use XML::Rabbit;

plan 3;

class TestMe does XML::Rabbit::Node {
    has $.x is xpath-object('TestA', '/xml/a');
}

class TestA does XML::Rabbit::Node {
    has $.value is xpath('.');
    has $.key is xpath('./@very');
}

my $f = TestMe.new(file => 't/example.xml');


isa-ok $f.x, 'TestA', 'created a object for /xml/a';
is $f.x.value, 'example', 'fetching singular value';
is $f.x.key, 'basic', 'fetching singular value';

done-testing;

