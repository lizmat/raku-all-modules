use v6;
use Test;
use Algorithm::Treap;

{
    my $treap = Algorithm::Treap.new(key-type => Int);
    $treap.insert(0,99);
    $treap.delete(0);

    my $actual = $treap.root;
    my $expected = Any;
    is $actual, $expected, "It should delete an item correctly";
}

{
    my $treap = Algorithm::Treap.new(key-type => Int);
    $treap.insert(0, 0, Num(0.51));
    $treap.insert(1, 1, Num(1.0));
    $treap.insert(2, 2, Num(0.28));
    $treap.insert(3, 3, Num(0.52));
    $treap.insert(4, 4, Num(0.24));
    $treap.delete(4);
    
    is $treap.root.key, 1, "It should delete a leaf correctly";
    is $treap.root.left-child.key, 0, "It should delete a leaf correctly";
    is $treap.root.right-child.key, 3, "It should delete a leaf correctly";
    is $treap.root.right-child.left-child.key, 2, "It should delete a leaf correctly";
}

{
    my $treap = Algorithm::Treap.new(key-type => Int);
    $treap.insert(0, 0, Num(0.51));
    $treap.insert(1, 1, Num(1.0));
    $treap.insert(2, 2, Num(0.28));
    $treap.insert(3, 3, Num(0.52));
    $treap.insert(4, 4, Num(0.24));
    $treap.delete(3);
    
    is $treap.root.key, 1, "It should delete a not-leaf node correctly";
    is $treap.root.left-child.key, 0, "It should delete a not-leaf node correctly";
    is $treap.root.right-child.key, 2, "It should delete a not-leaf node correctly";
    is $treap.root.right-child.right-child.key,4 ,"It should delete a not-leaf node correctly";
}

{
    my $treap = Algorithm::Treap.new(key-type => Int);
    $treap.insert(0, 0, Num(0.51));
    $treap.insert(1, 1, Num(1.0));
    $treap.insert(2, 2, Num(0.28));
    $treap.insert(3, 3, Num(0.52));
    $treap.insert(4, 4, Num(0.24));
    $treap.delete(1);

    is $treap.root.key, 3, "It should delete a root correctly";
    is $treap.root.left-child.key, 0, "It should delete a root correctly";
    is $treap.root.right-child.key, 4, "It should delete a root correctly";
    is $treap.root.left-child.right-child.key, 2, "It should delete a root correctly";
}

{
    my $treap = Algorithm::Treap.new(key-type => Int);
    $treap.insert(0, 0, Num(1.0));
    $treap.insert(1, 1, Num(0.9));
    $treap.insert(2, 2, Num(0.8));
    $treap.insert(3, 3, Num(0.7));
    $treap.insert(4, 4, Num(0.6));
    $treap.delete(3);

    is $treap.root.key, 0, "It should delete an item in the non-binary-shaped treap correctly";
    is $treap.root.right-child.key, 1, "It should delete an item in the non-binary-shaped treap correctly";
    is $treap.root.right-child.right-child.key, 2, "It should delete an item in the non-binary-shaped treap correctly";
    is $treap.root.right-child.right-child.right-child.key, 4, "It should delete an item in the non-binary-shaped treap correctly";
}

done-testing;
