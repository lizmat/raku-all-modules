use v6;
use Test;
use Algorithm::TernarySearchTree;

{
    my $tst = Algorithm::TernarySearchTree.new();
    $tst.insert("cat");
    $tst.insert("bug");
    $tst.insert("cats");
    $tst.insert("up");

    is $tst.contains("cat"), True, 'It should contains "cat"';
    is $tst.contains("bug"), True, 'It should contains "bug"';
    is $tst.contains("cats"), True, 'It should contains "cats"';
    is $tst.contains("up"), True, 'It should contains "up"';
    is $tst.contains("dog"), False, 'It shouldn\'t contains "dog"';
    is $tst.contains("cbug"), False, 'It shouldn\'t contains "cbug"';
    is $tst.contains("cup"), False, 'It shouldn\'t contains "cup"';
    is $tst.contains("bu"), False, 'It shouldn\'t contains "bu"';
}

{
    my $tst = Algorithm::TernarySearchTree.new();
    $tst.insert("");
    is $tst.contains(""), False, 'It shouldn\'t contains empty string';
}


done-testing;
