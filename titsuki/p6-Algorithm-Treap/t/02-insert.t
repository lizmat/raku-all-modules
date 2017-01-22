use v6;
use Test;
use Algorithm::Treap;

{
    my $treap = Algorithm::Treap[Str].new;
    dies-ok { $treap.insert(0, 99); }, "It should quit insertion and die when it violates type constraints";

}

{
    my $treap = Algorithm::Treap[Int].new;
    $treap.insert(0, 99);
    my $actual = $treap.root.value;
    my $expected = 99;
    is $actual, $expected, "It should insert an Int item";
}

{
    my $treap = Algorithm::Treap[Str].new;
    $treap.insert('aho-corasick', 99);
    my $actual = $treap.root.value;
    my $expected = 99;
    is $actual, $expected, "It should insert an Str item";
}

{
    my $treap = Algorithm::Treap[Int].new;
    $treap.insert(0, 99);
    $treap.insert(0, 101);
    my $actual = $treap.root.value;
    my $expected = 101;
    is $actual, $expected, "It should overwrite an item";
}

{
    my $treap = Algorithm::Treap[Int].new;
    $treap.insert(0, 0, Num(0.51));
    $treap.insert(1, 1, Num(1.0));
    $treap.insert(2, 2, Num(0.28));
    $treap.insert(3, 3, Num(0.52));
    $treap.insert(4, 4, Num(0.24));
    
    is $treap.root.key, 1, "It should insert an item with keeping heap order";
    is $treap.root.left-child.key, 0, "It should insert an item with keeping heap order";
    is $treap.root.right-child.key, 3, "It should insert an item with keeping heap order";
    is $treap.root.right-child.left-child.key, 2, "It should insert an item with keeping heap order";
    is $treap.root.right-child.right-child.key, 4, "It should insert an item with keeping heap order";
}

{
    my $treap = Algorithm::Treap[Int].new;
    $treap.insert(0, 0, Num(1.0));
    $treap.insert(1, 1, Num(0.9));
    $treap.insert(2, 2, Num(0.8));
    $treap.insert(3, 3, Num(0.7));
    $treap.insert(4, 4, Num(0.6));
    $treap.insert(3, 3, Num(0.5));

    is $treap.root.key, 0, "It should overwrite an item with keeping heap order";
    is $treap.root.right-child.key, 1, "It should overwrite an item with keeping heap order";
    is $treap.root.right-child.right-child.key, 2, "It should overwrite an item with keeping heap order";
    is $treap.root.right-child.right-child.right-child.key, 4, "It should overwrite an item with keeping heap order";
    is $treap.root.right-child.right-child.right-child.left-child.key, 3, "It should overwrite an item with keeping heap order";
}

done-testing;
