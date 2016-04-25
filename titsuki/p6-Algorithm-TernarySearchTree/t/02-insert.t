use v6;
use Test;
use Algorithm::TernarySearchTree;

{
    my $tst = Algorithm::TernarySearchTree.new();
    $tst.insert("cat");
    is $tst.root.split-char, "c", 'It should store "cat"';
    is $tst.root.eqkid.split-char, "a", 'It should store "cat"';
    is $tst.root.eqkid.eqkid.split-char, "t", 'It should store "cat"';
}

{
    my $tst = Algorithm::TernarySearchTree.new();
    $tst.insert("");
    is $tst.root, Any, 'It shouldn\'t store empty string';
}

{
    my $tst = Algorithm::TernarySearchTree.new();
    $tst.insert("cat");
    $tst.insert("bug");
    $tst.insert("cats");
    $tst.insert("up");

    # $ means record separator
    #    c
    #  / |  \
    # b  a   u
    # |  |   |
    # u  t   p
    # |  |   |
    # g  $   $
    # |   \
    # $    s
    #      |
    #      $
    is $tst.root.split-char, "c", 'It should store "cat", "bug", "cats", "up"';
    is $tst.root.lokid.split-char, "b", 'It should store "cat", "bug", "cats", "up"';
    is $tst.root.lokid.eqkid.split-char, "u", 'It should store "cat", "bug", "cats", "up"';
    is $tst.root.lokid.eqkid.eqkid.split-char, "g", 'It should store "cat", "bug", "cats", "up"';
    is $tst.root.lokid.eqkid.eqkid.eqkid.split-char, '30'.chr, 'It should store "cat", "bug", "cats", "up"';
    
    is $tst.root.eqkid.split-char, "a", 'It should store "cat", "bug", "cats", "up"';
    is $tst.root.eqkid.eqkid.split-char, "t", 'It should store "cat", "bug", "cats", "up"';
    is $tst.root.eqkid.eqkid.eqkid.split-char, '30'.chr, 'It should store "cat", "bug", "cats", "up"';
    is $tst.root.eqkid.eqkid.eqkid.hikid.split-char, "s", 'It should store "cat", "bug", "cats", "up"';
    is $tst.root.eqkid.eqkid.eqkid.hikid.eqkid.split-char, '30'.chr, 'It should store "cat", "bug", "cats", "up"';

    is $tst.root.hikid.split-char, "u", 'It should store "cat", "bug", "cats", "up"';
    is $tst.root.hikid.eqkid.split-char, "p", 'It should store "cat", "bug", "cats", "up"';
    is $tst.root.hikid.eqkid.eqkid.split-char, '30'.chr, 'It should store "cat", "bug", "cats", "up"';
}

done-testing;

