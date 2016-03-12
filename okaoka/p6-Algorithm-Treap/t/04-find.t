use v6;
use Test;
use Algorithm::Treap;
use Algorithm::Treap::Node;

{
    my $treap = Algorithm::Treap.new(key-type => Int);
    $treap.insert(0, 0, Num(0.51));
    $treap.insert(1, 1, Num(1.0));
    $treap.insert(2, 2, Num(0.28));
    $treap.insert(3, 3, Num(0.52));
    $treap.insert(4, 4, Num(0.24));

    my $actual = $treap.find(0);
    my $expected = Algorithm::Treap::Node.new(key => 0, value => 0, priority => Num(0.51));
    is $actual.key.WHAT, Int, "It should keep the key as a Int item";
    is-deeply $actual, $expected, "It should find an Int item";
}

{
    my $treap = Algorithm::Treap.new(key-type => Str);
    $treap.insert('a', 0, Num(0.51));
    $treap.insert('b', 1, Num(1.0));
    $treap.insert('c', 2, Num(0.28));
    $treap.insert('d', 3, Num(0.52));
    $treap.insert('e', 4, Num(0.24));

    my $actual = $treap.find('e');
    my $expected = Algorithm::Treap::Node.new(key => 'e', value => 4, priority => Num(0.24));
    is $actual.key.WHAT, Str, "It should keep the key as a Str item";
    is-deeply $actual, $expected, "It should find a Str item";
}

{
    my $treap = Algorithm::Treap.new(key-type => Int);
    $treap.insert(0, 0, Num(0.51));
    $treap.insert(1, 1, Num(1.0));
    $treap.insert(2, 2, Num(0.28));
    $treap.insert(3, 3, Num(0.52));
    $treap.insert(4, 4, Num(0.24));

    my $actual = $treap.find(4);
    my $expected = Algorithm::Treap::Node.new(key => 4, value => 4, priority => Num(0.24));
    is-deeply $actual, $expected, "It should find a leaf";
}

{
    my $treap = Algorithm::Treap.new(key-type => Int);
    $treap.insert(0, 0, Num(0.51));
    $treap.insert(1, 1, Num(1.0));
    $treap.insert(2, 2, Num(0.28));
    $treap.insert(3, 3, Num(0.52));
    $treap.insert(4, 4, Num(0.24));

    my $actual = $treap.find(10);
    my $expected = Any;
    is-deeply $actual, $expected, "It should return Any when it doesn't hit any items";
}

{
    my $treap = Algorithm::Treap.new(key-type => Int);
    $treap.insert(0, 0, Num(0.51));
    $treap.insert(1, 1, Num(1.0));
    $treap.insert(2, 2, Num(0.28));
    $treap.insert(3, 3, Num(0.52));
    $treap.insert(4, 4, Num(0.24));

    my $actual = $treap.find-value(0);
    my $expected = 0;
    is-deeply $actual, $expected, "It should find a value of an item";
}

{
    my $treap = Algorithm::Treap.new(key-type => Int);
    $treap.insert(0, 0, Num(0.51));
    $treap.insert(1, 1, Num(1.0));
    $treap.insert(2, 2, Num(0.28));
    $treap.insert(3, 3, Num(0.52));
    $treap.insert(4, 4, Num(0.24));

    my $actual = $treap.find-value(4);
    my $expected = 4;
    is-deeply $actual, $expected, "It should find a value of a leaf";
}

{
    my $treap = Algorithm::Treap.new(key-type => Int);
    $treap.insert(0, 0, Num(0.51));
    $treap.insert(1, 1, Num(1.0));
    $treap.insert(2, 2, Num(0.28));
    $treap.insert(3, 3, Num(0.52));
    $treap.insert(4, 4, Num(0.24));

    my $actual = $treap.find-value(10);
    my $expected = Any;
    is-deeply $actual, $expected, "It should return Any when it doesn't hit any items";
}

done-testing;
