use v6;
use Test;
use Algorithm::Treap;

{
    my $treap = Algorithm::Treap.new(key-type => Int);
    $treap.insert(0,1);
    $treap.insert(9,2);
    $treap.insert(20,3);
    $treap.insert(30,4);
    $treap.insert(40,5);
    my $actual = $treap.find-last-key();
    my $expected = 40;
    is $actual, $expected, "It should get maximum key in numerical order (asc)";
}

{
    my $treap = Algorithm::Treap.new(key-type => Int, order-by => 'desc');
    $treap.insert(0,1);
    $treap.insert(9,2);
    $treap.insert(20,3);
    $treap.insert(30,4);
    $treap.insert(40,5);
    my $actual = $treap.find-last-key();
    my $expected = 0;
    is $actual, $expected, "It should get maximum key in numerical order (desc)";
}

{
    my $treap = Algorithm::Treap.new(key-type => Str);
    $treap.insert('0',1);
    $treap.insert('9',2);
    $treap.insert('20',3);
    $treap.insert('30',4);
    $treap.insert('40',5);
    my $actual = $treap.find-last-key();
    my $expected = '9';
    is $actual, $expected, "It should get maximum key in lexicographical order (asc)";
}

{
    my $treap = Algorithm::Treap.new(key-type => Str, order-by => 'desc');
    $treap.insert('0',1);
    $treap.insert('9',2);
    $treap.insert('20',3);
    $treap.insert('30',4);
    $treap.insert('40',5);
    my $actual = $treap.find-last-key();
    my $expected = '0';
    is $actual, $expected, "It should get maximum key in lexicographical order (desc)";
}

{
    my $treap = Algorithm::Treap.new(key-type => Int);
    my $actual = $treap.find-last-key();
    my $expected = Any;
    is $actual, $expected, "It should return Any when it doesn't hit any keys";
}

done-testing;
