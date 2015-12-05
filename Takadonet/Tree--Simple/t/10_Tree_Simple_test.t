use v6;
use Test;
plan 275;
use lib <lib blib>;


eval-lives-ok 'use Tree::Simple', 'Can use Tree::Simple';

use Tree::Simple;



## ----------------------------------------------------------------------------
## Test for Tree::Simple
## ----------------------------------------------------------------------------
# NOTE:
# This test checks the base functionality of the Tree::Simple object. The test
# is so large because (at the moment) each test relies upon the tree created 
# by the previous tests. It is not the most efficient or sensible thing to do
# i know, but its how it is for now. There are close to 300 tests here, so 
# splitting them up would be a chore. 
## ----------------------------------------------------------------------------

# and that our ROOT constant is properly defined
is($Tree::Simple::ROOT, 'root');

# make a root for our tree
# my $tree = Tree::Simple->new("root tree", Tree::Simple->ROOT);
#see if we can do positional based as well as named based

my $tree = Tree::Simple.new("root tree",$Tree::Simple::ROOT);

ok($tree ~~ Tree::Simple, 'Tree::Simple object');

# test the interface

#todo need to test to see if they exist since they are private
#can_ok($tree, '_init');
#can_ok($tree, '_setParent');


my @methods= < new isRoot isLeaf setNodeValue getNodeValue getDepth fixDepth getParent 
getChildCount addChild addChildren  removeChildAt removeChild
getChild getAllChildren addSibling addSiblings  insertSiblings getSibling
getAllSiblings traverse accept clone cloneShallow DESTROY getUID>;
#insertChild insertChildren insertSibling

for @methods -> $method {
    ok $tree.can($method),"Can do method '$method'";
}

 

# verfiy that it is a root
ok($tree.isRoot());

# and since it has no children
# it is also a leaf node
ok($tree.isLeaf());

# check the value of the node,
# it should be root
is($tree.getNodeValue(), "root tree", '... this tree is a root');

# we have no children yet
is($tree.getChildCount(),  0, '... we have no children yet');

# check the depth
is($tree.getDepth(),  -1, '... we have no depth yet');

# check the index
is($tree.getIndex(), -1, '... root trees have no index');


is($tree.getUID(), $tree.getUID(), '... UIDs match for the same object');


ok $tree.can('setUID');
$tree.setUID("This is our unique identifier");

is($tree.getUID(), 'This is our unique identifier', '... UIDs match what we have set it to');

## ----------------------------------------------------------------------------
## testing adding children
## ----------------------------------------------------------------------------

# create a child

my $sub_tree = Tree::Simple.new('1.0');
ok($sub_tree ~~ Tree::Simple, 'Tree::Simple object');


# check the node value
is($sub_tree.getNodeValue(), "1.0", '... this tree is 1.0');

# since we have not assigned a parent it 
# will still be considered a root
ok($sub_tree.isRoot());

# and since it has no children
# it is also a leaf node
ok($sub_tree.isLeaf());	

# now add the child to our root
$tree.addChild($sub_tree);

# tree is no longer a leaf node
# now that we have a child
ok(!$tree.isLeaf());

# now that we have assigned a parent it
# will no longer be considered a root
ok(!$sub_tree.isRoot());

# check the depth of the sub_tree
is($sub_tree.getDepth(), 0, '... depth should be 0 now');

# check the index
is($sub_tree.getIndex(), 0, '... index should be 0 now');

# check the child count, 
# it should be one now
is($tree.getChildCount(), 1, '... we should have 1 children now');

# get the child we inserted
# and compare it with sub_tree
# they should be the same
is($tree.getChild(0), $sub_tree, '... make sure our sub_tree is fetchable');

# get the parent of sub_tree
my $sub_tree_parent = $sub_tree.getParent();

# now test that the parent of
# our sub_tree is the same as
# our root	
is($tree, $sub_tree_parent, '... make sure our sub_tree parent is tree');

## ----------------------------------------------------------------------------
## testing adding siblings
## ----------------------------------------------------------------------------
	
# create another sub_tree
my $sub_tree_2 = Tree::Simple.new("2.0");
ok($sub_tree_2 ~~ Tree::Simple, 'Tree::Simple object');

# check its node value
is($sub_tree_2.getNodeValue(), "2.0", '... this tree is 2.0');

# since we have not assigned a parent to 
# the new sub_tree it will still be
# considered a root
ok($sub_tree_2.isRoot());

# and since it has no children
# it is also a leaf node
ok($sub_tree_2.isLeaf());

# add our new subtree as a sibling
# of our first sub_tree
$sub_tree.addSibling($sub_tree_2);

# now that we have assigned a parent to
# the new sub_tree, it will no longer be 
# considered a root
ok(!$sub_tree_2.isRoot());

# check the depth of the sub_tree
is($sub_tree_2.getDepth(), 0, '... depth should be 0 now');

# check the index
is($sub_tree_2.getIndex(), 1, '... index should be 1');

# make sure that we now have 2 children in our root	
is($tree.getChildCount(), 2, '... we should have 2 children now');	

# and verify that the child at index 1
# is actually our second sub_tree	
is($tree.getChild(1), $sub_tree_2, '... make sure our sub_tree is fetchable');	
	
# get the parent of our second sub_tree
my $sub_tree_2_parent = $sub_tree_2.getParent();

# and make sure that it is the 
# same as our root
is($tree, $sub_tree_2_parent, '... make sure our sub_tree_2 parent is tree');
	
## ----------------------------------------------------------------------------
## test adding child by giving parent as a constructor argument
## ----------------------------------------------------------------------------	

# we create our new sub_tree and attach it
# to our root through its constructor
my $sub_tree_4 = Tree::Simple.new("4.0", $tree); 	

# check its node value
is($sub_tree_4.getNodeValue(), "4.0", '... this tree is 4.0');

# since we have assigned a parent to
# the new sub_tree, it will no longer be 
# considered a root
ok(!$sub_tree_4.isRoot());

# check the depth of the sub_tree
is($sub_tree_4.getDepth(), 0, '... depth should be 0 now');

# check the index
is($sub_tree_4.getIndex(), 2, '... index should be 2 now');

# but since it has no children
# it is also a leaf node
ok($sub_tree_4.isLeaf());

# make sure that we now have 3 children in our root	
is($tree.getChildCount(), 3, '... we should have 3 children now');

# and verify that the child at index 2
# is actually our latest sub_tree	
is($tree.getChild(2), $sub_tree_4, '... make sure our sub_tree is fetchable');	

# and make sure that the new sub-trees
# parent is the same as our root
is($tree, $sub_tree_4.getParent(), '... make sure our sub_tree_4 parent is tree');

## ----------------------------------------------------------------------------
## test inserting child 
## ----------------------------------------------------------------------------	

# we create our new sub_tree 
my $sub_tree_3 = Tree::Simple.new("3.0"); 	

# check its node value
is($sub_tree_3.getNodeValue(), "3.0", '... this tree is 3.0');

# since we have not assigned a parent to 
# the new sub_tree it will still be
# considered a root
ok($sub_tree_3.isRoot());

# but since it has no children
# it is also a leaf node
ok($sub_tree_3.isLeaf());

# now insert the child at index 2
$tree.insertChild(2, $sub_tree_3);

# since we now have assigned a parent to
# the new sub_tree, it will no longer be 
# considered a root
ok(!$sub_tree_3.isRoot());

# check the depth of the sub_tree
is($sub_tree_3.getDepth(), 0, '... depth should be 0 now');

# check the index of 3
is($sub_tree_3.getIndex(), 2, '... index should be 2 now');

# check the index of 4 now
is($sub_tree_4.getIndex(), 3, '... index should be 3 now');

# make sure that we now have 3 children in our root	
is($tree.getChildCount(), 4, '... we should have 4 children now');

# and verify that the child at index 2
# is actually our latest sub_tree	
is($tree.getChild(2), $sub_tree_3, '... make sure our sub_tree is fetchable');	

# and verify that the child that was 
# at index 2 is actually now actually
# at index 3	
is($tree.getChild(3), $sub_tree_4, '... make sure our sub_tree is fetchable');	

# and make sure that the new sub-trees
# parent is the same as our root
is($tree, $sub_tree_3.getParent(), '... make sure our sub_tree_3 parent is tree');	

## ----------------------------------------------------------------------------
## test getting all children and siblings
## ----------------------------------------------------------------------------	

# get it in scalar context and
# check that our arrays are equal
my $children = $tree.getAllChildren();

is-deeply($children, [ $sub_tree, $sub_tree_2, $sub_tree_3, $sub_tree_4]);

# get it in array context and
# check that our arrays are equal
my @children = $tree.getAllChildren();
is-deeply(@children, [ $sub_tree, $sub_tree_2, $sub_tree_3, $sub_tree_4 ]);

# check that the values from both
# contexts are equal to one another
is-deeply($children, @children);

# now check that the siblings of all the 
# sub_trees are the same as the children
for @children ->  $_sub_tree {
	# test siblings in scalar context
	my $siblings = $sub_tree.getAllSiblings();
	is-deeply($children, $siblings);
	# and now in array context
	my @siblings = $sub_tree.getAllSiblings();
	is-deeply($children, @siblings);
}

## ----------------------------------------------------------------------------
## test addChildren
## ----------------------------------------------------------------------------	

my @sub_children = (
 			Tree::Simple.new("1.1"),
			Tree::Simple.new("1.5"),
			Tree::Simple.new("1.6")
			);

# now go through the children and test them
for @sub_children ->  $sub_child {
 	# they should think they are root
 	ok($sub_child.isRoot());

 	# and they should all be leaves
 	ok($sub_child.isLeaf());

 	# and their node values
        #todo nyi in Test.pm
# 	like($sub_child.getNodeValue(), qr/1\.[0-9]/, '... they at least have "1." followed by a digit');
	
 	# and they should all have a depth of -1
 	is($sub_child.getDepth(), -1, '... depth should be -1');	
}

# check to see if we can add children
$sub_tree.addChildren(@sub_children);

# we are no longer a leaf node now
ok(!$sub_tree.isLeaf());

# make sure that we now have 3 children now	
is($sub_tree.getChildCount(), 3, '... we should have 3 children now');

# now check that sub_tree's children 
# are the same as our list
is-deeply([ $sub_tree.getAllChildren() ], @sub_children);

# now go through the children again
# and test them
for @sub_children -> $sub_child {
 	# they should no longer think
 	# they are root
 	ok(!$sub_child.isRoot());
	
 	# but they should still think they 
 	# are leaves
 	ok($sub_child.isLeaf());
	
 	# now we test their parental relationship
 	is($sub_tree, $sub_child.getParent(), '... their parent is the sub_tree');
	
 	# and they should all have a depth of 1
 	is($sub_child.getDepth(), 1, '... depth should be 1');
	
 	# now check that its siblings are the same 
 	# as the children of its parent			
 	is-deeply([ $sub_tree.getAllChildren() ], [ $sub_child.getAllSiblings() ]);
}

## ----------------------------------------------------------------------------
## test insertingChildren
## ----------------------------------------------------------------------------	

my @more_sub_children = (
  			Tree::Simple.new("1.2"),
 			Tree::Simple.new("1.3"),
 			Tree::Simple.new("1.4")
			);

# now go through the children and test them
for @more_sub_children -> $sub_child {
 	# they should think they are root
 	ok($sub_child.isRoot());

 	# and they should all be leaves
 	ok($sub_child.isLeaf());

 	# and their node values
        #todo nyi in Test.pm
# 	like($sub_child.getNodeValue(), qr/1\.[0-9]/, '... they at least have "1." followed by a digit');
	
 	# and they should all have a depth of -1
 	is($sub_child.getDepth(), -1, '... depth should be -1');	
}

# check to see if we can insert children
$sub_tree.insertChildren(1, @more_sub_children);

# make sure that we now have 6 children now	
is($sub_tree.getChildCount(), 6, '... we should have 6 children now');

# now check that sub_tree's children 
# are the same as our list
is-deeply([ $sub_tree.getAllChildren() ], [ @sub_children[0], @more_sub_children, @sub_children[1 .. @sub_children.end()] ]);

# now go through the children again
# and test them
for @more_sub_children -> $sub_child {
 	# they should no longer think
 	# they are roots
 	ok(!$sub_child.isRoot());
	
 	# but they should still think they 
 	# are leaves
 	ok($sub_child.isLeaf());
	
 	# now we test their parental relationship
 	is($sub_tree, $sub_child.getParent(), '... their parent is the sub_tree');
	
 	# and they should all have a depth of 1
 	is($sub_child.getDepth(), 1, '... depth should be 1');
	
 	# now check that its siblings are the same 
 	# as the children of its parent
 	is-deeply([ $sub_tree.getAllChildren() ], [ $sub_child.getAllSiblings() ]);
}

## ----------------------------------------------------------------------------
## test addingSiblings
## ----------------------------------------------------------------------------	

 my @more_children = (
  			Tree::Simple.new("5.0"),
 			Tree::Simple.new("9.0")
 			);

# now go through the children and test them
for @more_children -> $sub_child {
 	# they should think they are root
 	ok($sub_child.isRoot());

 	# and they should all be leaves
 	ok($sub_child.isLeaf());

 	# and their node values
        #todo nyi in Test.pm
 	#like($sub_child.getNodeValue(), qr/[0-9]\.0/, '... they at least have digit followed by ".0"');
	
 	# and they should all have a depth of -1
 	is($sub_child.getDepth(), -1, '... depth should be -1');	
}

# check to see if we can insert children
$sub_tree.addSiblings(@more_children);

# make sure that we now have 6 children now	
is($tree.getChildCount(), 6, '... we should have 6 children now');

# now check that tree's new children 
# are the same as our list
is($tree.getChild(4), @more_children[0], '... they are the same');
is($tree.getChild(5), @more_children[1], '... they are the same');

# now go through the children again
# and test them
for @more_children -> $sub_child {
 	# they should no longer think
 	# they are roots
 	ok(!$sub_child.isRoot());
	
 	# but they should still think they 
 	# are leaves
 	ok($sub_child.isLeaf());
	
 	# now we test their parental relationship
 	is($tree, $sub_child.getParent(), '... their parent is the tree');
	
 	# and they should all have a depth of 1
 	is($sub_child.getDepth(), 0, '... depth should be 0');
	
 	# now check that its siblings are the same 
 	# as the children of its parent			
 	is-deeply([ $tree.getAllChildren() ], [ $sub_child.getAllSiblings() ]);
}

## ----------------------------------------------------------------------------
## test insertSibling
## ----------------------------------------------------------------------------	

my $new_sibling = Tree::Simple.new("8.0"); 

# they should think they are root
ok($new_sibling.isRoot());

# and they should all be leaves
ok($new_sibling.isLeaf());

# and their node values
is($new_sibling.getNodeValue(), "8.0", '... node value should be 6.0');

# and they should all have a depth of -1
is($new_sibling.getDepth(), -1, '... depth should be -1');	

# check to see if we can insert children
$sub_tree.insertSibling(5, $new_sibling);

# make sure that we now have 6 children now	
is($tree.getChildCount(), 7, '... we should have 7 children now');

# now check that sub_tree's new sibling
# is in the right place and that it 
# should have displaced the old value at
# that index to index + 1 
is($tree.getChild(4), @more_children[0], '... they are the same');
is($tree.getChild(5), $new_sibling, '... they are the same');
is($tree.getChild(6), @more_children[1], '... they are the same');

# they should no longer think
# they are roots
ok(!$new_sibling.isRoot());

# but they should still think they 
# are leaves
ok($new_sibling.isLeaf());

# now we test their parental relationship
is($tree, $new_sibling.getParent(), '... their parent is the tree');

# and they should all have a depth of 1
is($new_sibling.getDepth(), 0, '... depth should be 0');
	
# now check that its siblings are the same 
# as the children of its parent			
is-deeply([ $tree.getAllChildren() ], [ $new_sibling.getAllSiblings() ]);

## ----------------------------------------------------------------------------
## test inserting Siblings
## ----------------------------------------------------------------------------	

my @even_more_children = (
  			Tree::Simple.new("6.0"),
 			Tree::Simple.new("7.0")
 			);

# now go through the children and test them
for @even_more_children -> $sub_child {
 	# they should think they are root
 	ok($sub_child.isRoot());

 	# and they should all be leaves
 	ok($sub_child.isLeaf());

 	# and their node values
        #todo nyi in Test.pm
# 	like($sub_child.getNodeValue(), qr/[0-9]\.0/, '... they at least have digit followed by ".0"');
	
 	# and they should all have a depth of -1
 	is($sub_child.getDepth(), -1, '... depth should be -1');	
}

# check to see if we can insert children
$sub_tree.insertSiblings(5, @even_more_children);

# make sure that we now have 6 children now	
is($tree.getChildCount(), 9, '... we should have 6 children now');

# now check that tree's new children 
# are the same as our list
is($tree.getChild(4), @more_children[0], '... they are the same');
is($tree.getChild(5), @even_more_children[0], '... they are the same');
is($tree.getChild(6), @even_more_children[1], '... they are the same');
is($tree.getChild(7), $new_sibling, '... they are the same');
is($tree.getChild(8), @more_children[1], '... they are the same');

# now go through the children again
# and test them
for @even_more_children ->  $sub_child {
 	# they should no longer think
 	# they are roots
 	ok(!$sub_child.isRoot());
	
 	# but they should still think they 
 	# are leaves
 	ok($sub_child.isLeaf());
	
 	# now we test their parental relationship
 	is($tree, $sub_child.getParent(), '... their parent is the tree');
	
 	# and they should all have a depth of 1
 	is($sub_child.getDepth(), 0, '... depth should be 0');
	
 	# now check that its siblings are the same 
 	# as the children of its parent			
 	is-deeply([ $tree.getAllChildren() ], [ $sub_child.getAllSiblings() ]);
}

## ----------------------------------------------------------------------------
## test getChild and getSibling
## ----------------------------------------------------------------------------	

# make sure that getChild returns the
# same as getSibling
for 0 .. $tree.getChildCount()  {
    is($tree.getChild($_), $sub_tree.getSibling($_), '... siblings are the same as children');
}        


## ----------------------------------------------------------------------------
## test self referential returns
## ----------------------------------------------------------------------------	

# addChildren's return value is actually $self
# so that method calls can be chained
my $self_ref_tree_test = Tree::Simple.new("3.1", $sub_tree_3).addChildren(
 									Tree::Simple.new("3.1.1"),
 									Tree::Simple.new("3.1.2")
 								);
# make sure that it true
ok($self_ref_tree_test ~~ Tree::Simple,'Should be a Tree::Simple');

# it shouldnt be a root
ok(!$self_ref_tree_test.isRoot());

# and it shouldnt be a leaf
ok(!$self_ref_tree_test.isLeaf());

# make sure that the parent in the constructor worked
is($sub_tree_3, $self_ref_tree_test.getParent(), '... should be the same');

# and the parents count should be 1
is($sub_tree_3.getChildCount(), 1, '... we should have 1 child here');

# make sure they show up in the count test
is($self_ref_tree_test.getChildCount(), 2, '... we should have 2 children here');

for $self_ref_tree_test.getAllChildren() -> $sub_child {
 	# they should not think
 	# they are roots
 	ok(!$sub_child.isRoot());
	
 	# but they should think they 
 	# are leaves
 	ok($sub_child.isLeaf());
	
 	# now we test their parental relationship
 	is($self_ref_tree_test, $sub_child.getParent(), '... their parent is the tree');
	
 	# and they should all have a depth of 1
 	is($sub_child.getDepth(), 2, '... depth should be 0');
	
 	# now check that its siblings are the same 
 	# as the children of its parent			
 	is-deeply([ $self_ref_tree_test.getAllChildren() ], [ $sub_child.getAllSiblings() ]);
}

## ----------------------------------------------------------------------------	
## Test self-referential version of addChild
## ----------------------------------------------------------------------------

# addChild's return value is actually $self
# so that method calls can be chained
my $self_ref_tree_test_2 = Tree::Simple.new("2.1", $sub_tree_2).addChild(
 									Tree::Simple.new("2.1.1")
 								);
# make sure that it true
ok($self_ref_tree_test_2 ~~ Tree::Simple);

# it shouldnt be a root
ok(!$self_ref_tree_test_2.isRoot());

# and it shouldnt be a leaf
ok(!$self_ref_tree_test_2.isLeaf());

# make sure that the parent in the constructor worked
is($sub_tree_2, $self_ref_tree_test_2.getParent(), '... should be the same');

# and the parents count should be 1
is($sub_tree_2.getChildCount(), 1, '... we should have 1 child here');

# make sure they show up in the count test
is($self_ref_tree_test_2.getChildCount(), 1, '... we should have 1 child here');

my $sub_child = $self_ref_tree_test_2.getChild(0);

# they should not think
# they are roots
ok(!$sub_child.isRoot());

# but they should think they 
# are leaves
ok($sub_child.isLeaf());

# now we test their parental relationship
is($self_ref_tree_test_2, $sub_child.getParent(), '... their parent is the tree');

# and they should all have a depth of 1
is($sub_child.getDepth(), 2, '... depth should be 0');

# now check that its siblings are the same 
# as the children of its parent		
is-deeply([ $self_ref_tree_test_2.getAllChildren() ], [ $sub_child.getAllSiblings() ]);

## ----------------------------------------------------------------------------
## test removeChildAt
## ----------------------------------------------------------------------------	

my $sub_tree_of_tree_to_remove = Tree::Simple.new("1.1.a.1");
# make a node to remove
my $tree_to_remove = Tree::Simple.new("1.1.a").addChild($sub_tree_of_tree_to_remove);

# test that its a root
ok($tree_to_remove.isRoot());

# and that its depth is -1
is($tree_to_remove.getDepth(), -1, '... the depth should be -1'); 
# and the sub-trees depth is 0
is($sub_tree_of_tree_to_remove.getDepth(), 0, '... the depth should be 0'); 

# insert it into the sub_tree
$sub_tree.insertChildren(1, $tree_to_remove);

# test that it no longer thinks its a root
ok(!$tree_to_remove.isRoot());

# check thats its depth is now 1
is($tree_to_remove.getDepth(), 1, '... the depth should be 1'); 
# and the sub-trees depth is 2
is($sub_tree_of_tree_to_remove.getDepth(), 2, '... the depth should be 2'); 

# make sure it is there
is($sub_tree.getChild(1), $tree_to_remove, '... these tree should be equal');		

# remove the subtree (it will be returned)
my $removed_tree = $sub_tree.removeChildAt(1);

# now check that the one removed it the one 
# we inserted origianlly
is($removed_tree, $tree_to_remove, '... these tree should be equal');

# it should think its a root again
ok($tree_to_remove.isRoot());
# and its depth should be back to -1
is($tree_to_remove.getDepth(), -1, '... the depth should be -1'); 
# and the sub-trees depth is 0
is($sub_tree_of_tree_to_remove.getDepth(), 0, '... the depth should be 0'); 	

## ----------------------------------------------------------------------------
## test removeChild
## ----------------------------------------------------------------------------	

my $sub_tree_of_tree_to_remove2 = Tree::Simple.new("1.1.a.1");
# make a node to remove
my $tree_to_remove2 = Tree::Simple.new("1.1.a").addChild($sub_tree_of_tree_to_remove2);

# test that its a root
ok($tree_to_remove2.isRoot());

# and that its depth is -1
is($tree_to_remove2.getDepth(), -1, '... the depth should be -1'); 
# and the sub-trees depth is 0
is($sub_tree_of_tree_to_remove2.getDepth(), 0, '... the depth should be 0'); 

# insert it into the sub_tree
$sub_tree.insertChild(1, $tree_to_remove2);

# test that it no longer thinks its a root
ok(!$tree_to_remove2.isRoot());

# check thats its depth is now 1
is($tree_to_remove2.getDepth(), 1, '... the depth should be 1'); 
# and the sub-trees depth is 2
is($sub_tree_of_tree_to_remove2.getDepth(), 2, '... the depth should be 2'); 

# make sure it is there
is($sub_tree.getChild(1), $tree_to_remove2, '... these tree should be equal');		

# remove the subtree (it will be returned)

my $removed_tree2 = $sub_tree.removeChild($tree_to_remove2);

# now check that the one removed it the one 
# we inserted origianlly
is($removed_tree2, $tree_to_remove2, '... these tree should be equal');

# it should think its a root again
ok($tree_to_remove2.isRoot());
# and its depth should be back to -1
is($tree_to_remove2.getDepth(), -1, '... the depth should be -1'); 
# and the sub-trees depth is 0
is($sub_tree_of_tree_to_remove2.getDepth(), 0, '... the depth should be 0'); 	

## ----------------------------------------------------------------------------
## test removeChild backwards compatability
## ----------------------------------------------------------------------------	

# make a node to remove
my $tree_to_remove3 = Tree::Simple.new("1.1.a");

# test that its a root
ok($tree_to_remove3.isRoot());

# and that its depth is -1
is($tree_to_remove3.getDepth(), -1, '... the depth should be -1'); 

# insert it into the sub_tree
$sub_tree.insertChild(1, $tree_to_remove3);

# test that it no longer thinks its a root
ok(!$tree_to_remove3.isRoot());

# check thats its depth is now 1
is($tree_to_remove3.getDepth(), 1, '... the depth should be 1'); 

# make sure it is there
is($sub_tree.getChild(1), $tree_to_remove3, '... these tree should be equal');		

# remove the subtree (it will be returned)
my $removed_tree3 = $sub_tree.removeChild(1);

# now check that the one removed it the one 
# we inserted origianlly
is($removed_tree3, $tree_to_remove3, '... these tree should be equal');

# it should think its a root again
ok($tree_to_remove3.isRoot());
# and its depth should be back to -1
is($tree_to_remove3.getDepth(), -1, '... the depth should be -1'); 

## ----------------------------------------------
## now test the edge cases
## ----------------------------------------------

# trees at the end

# make a node to remove
my $tree_to_remove_2 = Tree::Simple.new("1.7");

# add it into the sub_tree
$sub_tree.addChild($tree_to_remove_2);

# make sure it is there
is($sub_tree.getChild($sub_tree.getChildCount() - 1), $tree_to_remove_2, '... these tree should be equal');		

# remove the subtree (it will be returned)
my $removed_tree_2 = $sub_tree.removeChildAt($sub_tree.getChildCount() - 1);

# now check that the one removed it the one 
# we inserted origianlly
is($removed_tree_2, $tree_to_remove_2, '... these tree should be equal');

# trees at the beginging

# make a node to remove
my $tree_to_remove_3 = Tree::Simple.new("1.1.-1");

# add it into the sub_tree
$sub_tree.insertChild(0, $tree_to_remove_3);

# make sure it is there
is($sub_tree.getChild(0), $tree_to_remove_3, '... these tree should be equal');		

# remove the subtree (it will be returned)
my $removed_tree_3 = $sub_tree.removeChildAt(0);

# now check that the one removed it the one 
# we inserted origianlly
is($removed_tree_3, $tree_to_remove_3, '... these tree should be equal');		

## ----------------------------------------------------------------------------
## test traverse
## ----------------------------------------------------------------------------	

# make a control set of 
# all the nodes we have
my @_all_node_values = <
	1.0 
		1.1 
		1.2
		1.3
		1.4
		1.5
		1.6
	2.0
		2.1
			2.1.1
	3.0
		3.1
			3.1.1
			3.1.2
	4.0
	5.0
	6.0
	7.0
	8.0
	9.0
	>;

my @all_node_values;
# now collect the nodes in the actual tree
$tree.traverse(sub ($_tree) {

 	push @all_node_values , $_tree.getNodeValue();
 	});

# and compare the two
is-deeply(@_all_node_values, @all_node_values, '... our nodes match our control nodes');

# test traverse with both pre- and post- methods
# make a control set of 
# all the nodes we have with XML-style
my @_all_node_values_post_traverse = <
	1.0 
 		1.1 
         1.1
 		1.2
         1.2
 		1.3
         1.3
 		1.4
         1.4
 		1.5
         1.5
 		1.6
         1.6
     1.0
 	2.0
 		2.1
 			2.1.1
             2.1.1
         2.1
     2.0
 	3.0
 		3.1
 			3.1.1
             3.1.1
 			3.1.2
             3.1.2
         3.1
     3.0
 	4.0
     4.0
 	5.0
     5.0
 	6.0
     6.0
 	7.0
     7.0
 	8.0
 	8.0
 	9.0
 	9.0
 	>;


my @all_node_values_post_traverse;
# now collect the nodes in the actual tree
$tree.traverse(sub ($_tree) {
 	    push @all_node_values_post_traverse, $_tree.getNodeValue();
 	},
     sub ($_tree) {
         push @all_node_values_post_traverse, $_tree.getNodeValue();
     }
);

# and compare the two
is-deeply(@_all_node_values_post_traverse, @all_node_values_post_traverse,
   '... our nodes match our control nodes for post traverse method');


## ----------------------------------------------------------------------------
## test size
## ----------------------------------------------------------------------------	

is($tree.size(), (@_all_node_values.elems() + 1), '... our size is as we expect it to be');

# NOTE:
# it is (@_all_node_values.elems() + 1) so that 
# we account for the root node which is not in 
# the list.

## ----------------------------------------------------------------------------
## test height
## ----------------------------------------------------------------------------	

is($tree.height(), 4, '... our height is as we expect it to be');

## ----------------------------------------------------------------------------
## test clone
## ----------------------------------------------------------------------------	

# clone the whole tree
my $tree_clone = $tree.clone();

my @all_cloned_node_values;
# collect all the cloned values
$tree_clone.traverse(sub ($_tree){
	push @all_cloned_node_values, $_tree.getNodeValue();
	});

# make sure that our cloned values equal to our control
is-deeply(@_all_node_values, @all_cloned_node_values);
# and make sure they also match the original tree
is-deeply(@all_node_values, @all_cloned_node_values);

# now change all the node values
$tree_clone.traverse(sub ($_tree){
 	$_tree.setNodeValue(". " ~ $_tree.getNodeValue());
 	});

my @all_cloned_node_values_changed;
# collect them again	
$tree_clone.traverse(sub ($_tree) {
 	push @all_cloned_node_values_changed , $_tree.getNodeValue();
 	});	

# make a copy of our control and cange it too
#todo no idea why it was '->' to '.' made it work...
#my @_all_node_values_changed = map { "-> $_" }, @_all_node_values;
my @_all_node_values_changed = map { ". $_" }, @_all_node_values;	

# now both our changed values should be correct
is-deeply(@_all_node_values_changed, @all_cloned_node_values_changed);

my @all_node_values_check;
# now traverse the original tree again and make sure
# that the nodes are not changed
$tree.traverse(sub ($_tree){
	push @all_node_values_check , $_tree.getNodeValue();
	});

# this can be accomplished by checking them 
# against our control again
is-deeply(@_all_node_values, @all_node_values_check);	
	
## ----------------------------------------------------------------------------
## end test for Tree::Simple
## ----------------------------------------------------------------------------	
