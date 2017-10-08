use v6;
use Test;
use Algorithm::TernarySearchTree;

{
    my $tst = Algorithm::TernarySearchTree.new();
    $tst.insert("cat");
    $tst.insert("bug");
    $tst.insert("cats");
    $tst.insert("up");

    is $tst.partial-match("."),set(), "It should match any strings with length 1";
    is $tst.partial-match(".."),set("up"), "It should match any strings with length 2";
    is $tst.partial-match("..."),set("cat","bug"), "It should match any strings with length 3";
    is $tst.partial-match("...."),set("cats"), "It should match any strings with length 4";
    is $tst.partial-match("....."),set(), "It should match any strings with length 5";

    is $tst.partial-match("cat."),set("cats"), 'It should match "cats"';
    is $tst.partial-match(".ats"),set("cats"), 'It should match "cats"';
    is $tst.partial-match("c.ts"),set("cats"), 'It should match "cats"';
    is $tst.partial-match("c..s"),set("cats"), 'It should match "cats"';
}

done-testing;
