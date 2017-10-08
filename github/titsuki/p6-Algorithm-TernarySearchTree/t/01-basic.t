use v6;
use Test;

use-ok 'Algorithm::TernarySearchTree';
use-ok 'Algorithm::TernarySearchTree::Node';

use Algorithm::TernarySearchTree;

lives-ok { my $tst = Algorithm::TernarySearchTree.new(); }

done-testing;
