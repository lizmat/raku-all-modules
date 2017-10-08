use v6;
use Test;
use Algorithm::Treap;

{
    my $treap = Algorithm::Treap[Int].new;
    $treap.insert(0,1);
    $treap.insert(9,2);
    $treap.insert(20,3);
    $treap.insert(30,4);
    $treap.insert(40,5);
    my $actual = $treap.find-first-key();
    my $expected = 0;
    is $actual, $expected, "It should get minimum key in numerical order (asc)";
}

{
    my $treap = Algorithm::Treap[Int].new(order-by => TOrder::DESC);
    $treap.insert(0,1);
    $treap.insert(9,2);
    $treap.insert(20,3);
    $treap.insert(30,4);
    $treap.insert(40,5);
    my $actual = $treap.find-first-key();
    my $expected = 40;
    is $actual, $expected, "It should get minimum key in numerical order (desc)";
}

{
    my $treap = Algorithm::Treap[Str].new;
    $treap.insert('0',1);
    $treap.insert('9',2);
    $treap.insert('20',3);
    $treap.insert('30',4);
    $treap.insert('40',5);
    my $actual = $treap.find-first-key();
    my $expected = '0';
    is $actual, $expected, "It should get minimum key in lexicographical order (asc)";
}

{
    my $treap = Algorithm::Treap[Str].new(order-by => TOrder::DESC);
    $treap.insert('0',1);
    $treap.insert('9',2);
    $treap.insert('20',3);
    $treap.insert('30',4);
    $treap.insert('40',5);
    my $actual = $treap.find-first-key();
    my $expected = '9';
    is $actual, $expected, "It should get minimum key in lexicographical order (desc)";
}

{
    my $treap = Algorithm::Treap[Int].new;
    my $actual = $treap.find-first-key();
    my $expected = Any;
    is $actual, $expected, "It should return Any when it doesn't hit any keys";
}

done-testing;
