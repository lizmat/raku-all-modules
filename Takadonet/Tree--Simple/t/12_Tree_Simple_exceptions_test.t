use v6;
use Test;
plan 50;
use lib <lib blib>;

use Tree::Simple;


## ----------------------------------------------------------------------------
## Exception Tests for Tree::Simple
## ----------------------------------------------------------------------------
class Bad { has $.node = 'Fail'};

my $BAD_OBJECT = Bad.new();

my $TEST_SUB_TREE = Tree::Simple.new("test");

# -----------------------------------------------
# exceptions for new
# -----------------------------------------------

# not giving a proper argument for parent

dies-ok( { Tree::Simple.new("test", 0) });

# not giving a proper argument for parent
dies-ok ( {
	Tree::Simple.new("test", []);
} );

# not giving a proper argument for parent
dies-ok( {
 	Tree::Simple.new("test", $BAD_OBJECT);
} ) ; # qr/^Insufficient Arguments \:/, '... this should die';

# -----------------------------------------------

my $tree = Tree::Simple.new($Tree::Simple::ROOT);

# -----------------------------------------------
# exceptions for setNodeValue
# -----------------------------------------------

# not giving an argument for setNodeValue
dies-ok( {
	$tree.setNodeValue();
} ) ; # qr/^Insufficient Arguments \: must supply a value for node/, '... this should die';

# -----------------------------------------------
# exceptions for addChild
# -----------------------------------------------

# not giving an argument for addChild
dies-ok( {
 	$tree.addChild();
} ) ; # qr/^Insufficient Arguments : no tree\(s\) to insert/, '... this should die';

# # giving an bad argument for addChild
dies-ok( {
 	$tree.addChild("fail");
} ) ; # qr/^Insufficient Arguments \: Child must be a Tree\:\:Simple object/, '... this should die';

# # giving an bad argument for addChild
dies-ok( {
 	$tree.addChild([]);
} ) ; # qr/^Insufficient Arguments \: Child must be a Tree\:\:Simple object/, '... this should die';


# # giving an bad object argument for addChild
dies-ok( {
 	$tree.addChild($BAD_OBJECT);
} ) ; # qr/^Insufficient Arguments \: Child must be a Tree\:\:Simple object/, '... this should die';

# -----------------------------------------------
# exceptions for insertChild
# -----------------------------------------------

#todo this will pass not because it validates the arguments but because their is no alias yet for InsertChild
# giving no index argument for insertChild
dies-ok( {
 	$tree.insertChild();
} ) ; # qr/^Insufficient Arguments \: Cannot insert child without index/, '... this should die';

# giving an out of bounds index argument for insertChild
dies-ok( {
 	$tree.insertChild(5);
} ) ; # qr/^Index Out of Bounds \: got \(5\) expected no more than \(0\)/, '... this should die';

# giving an good index argument but no tree argument for insertChild
dies-ok( {
 	$tree.insertChild(0);
} ) ; # qr/^Insufficient Arguments \: no tree\(s\) to insert/, '... this should die';

# giving an good index argument but an undefined tree argument for insertChild
dies-ok( {
 	$tree.insertChild(0, Mu);
} ) ; # qr/^Insufficient Arguments \: Child must be a Tree\:\:Simple object/, '... this should die';

# giving an good index argument but a non-object tree argument for insertChild
dies-ok( {
 	$tree.insertChild(0, "Fail");
} ) ; # qr/^Insufficient Arguments \: Child must be a Tree\:\:Simple object/, '... this should die';

# # giving an good index argument but a non-object-ref tree argument for insertChild
dies-ok( {
 	$tree.insertChild(0, []);
} ) ; # qr/^Insufficient Arguments \: Child must be a Tree\:\:Simple object/, '... this should die';


# # giving an good index argument but a bad object tree argument for insertChild
dies-ok( {
 	$tree.insertChild(0, $BAD_OBJECT);
} ) ; # qr/^Insufficient Arguments \: Child must be a Tree\:\:Simple object/, '... this should die';


# -----------------------------------------------
# exceptions for insertChildAt
# -----------------------------------------------

# giving no index argument for insertChildAt
dies-ok( {
 	$tree.insertChildAt();
} ) ; # qr/^Insufficient Arguments \: Cannot insert child without index/, '... this should die';

# giving an out of bounds index argument for insertChildAt
dies-ok( {
 	$tree.insertChildAt(5);
} ) ; # qr/^Index Out of Bounds \: got \(5\) expected no more than \(0\)/, '... this should die';

# giving an good index argument but no tree argument for insertChildAt
dies-ok( {
 	$tree.insertChildAt(0);
} ) ; # qr/^Insufficient Arguments \: no tree\(s\) to insert/, '... this should die';

# giving an good index argument but an undefined tree argument for insertChildAt
dies-ok( {
 	$tree.insertChildAt(0, Mu);
} ) ; # qr/^Insufficient Arguments \: Child must be a Tree\:\:Simple object/, '... this should die';

# giving an good index argument but a non-object tree argument for insertChildAt
dies-ok( {
 	$tree.insertChildAt(0, "Fail");
} ) ; # qr/^Insufficient Arguments \: Child must be a Tree\:\:Simple object/, '... this should die';

# # giving an good index argument but a non-object-ref tree argument for insertChildAt
dies-ok( {
 	$tree.insertChildAt(0, []);
} ) ; # qr/^Insufficient Arguments \: Child must be a Tree\:\:Simple object/, '... this should die';


# # giving an good index argument but a bad object tree argument for insertChildAt
dies-ok( {
 	$tree.insertChildAt(0, $BAD_OBJECT);
} ) ; # qr/^Insufficient Arguments \: Child must be a Tree\:\:Simple object/, '... this should die';


# -----------------------------------------------
# exceptions for insertChildren
# -----------------------------------------------
# NOTE:
# even though insertChild and insertChildren are
# implemented in the same function, it makes sense
# to future-proof our tests by checking it anyway
# this will help to save us the trouble later on

#todo this will pass not because it validates the arguments but because their is no alias yet for insertChildren

# giving no index argument for insertChild
dies-ok( {
 	$tree.insertChildren();
} ) ; # qr/^Insufficient Arguments \: Cannot insert child without index/, '... this should die';

# giving an out of bounds index argument for insertChild
dies-ok( {
 	$tree.insertChildren(5);
} ) ; # qr/^Index Out of Bounds \: got \(5\) expected no more than \(0\)/, '... this should die';

# giving an good index argument but no tree argument for insertChild
dies-ok( {
 	$tree.insertChildren(0);
} ) ; # qr/^Insufficient Arguments \: no tree\(s\) to insert/, '... this should die';

# giving an good index argument but a Mu tree argument for insertChild
dies-ok( {
 	$tree.insertChildren(0, Mu);
} ) ; # qr/^Insufficient Arguments \: Child must be a Tree\:\:Simple object/, '... this should die';

# giving an good index argument but a non-object tree argument for insertChild
dies-ok( {
 	$tree.insertChildren(0, "Fail");
} ) ; # qr/^Insufficient Arguments \: Child must be a Tree\:\:Simple object/, '... this should die';

# giving an good index argument but a non-object-ref tree argument for insertChild
dies-ok( {
 	$tree.insertChildren(0, []);
} ) ; # qr/^Insufficient Arguments \: Child must be a Tree\:\:Simple object/, '... this should die';


# giving an good index argument but a bad object tree argument for insertChild
dies-ok( {
 	$tree.insertChildren(0, $BAD_OBJECT);
} ) ; # qr/^Insufficient Arguments \: Child must be a Tree\:\:Simple object/, '... this should die';


# -----------------------------------------------
# exceptions for removeChildAt
# -----------------------------------------------

# giving no index argument for removeChildAt
dies-ok( {
 	$tree.removeChildAt();
} ) ; # qr/^Insufficient Arguments \: Cannot remove child without index/, '... this should die';

# attempt to remove a child when there are none
dies-ok( {
 	$tree.removeChildAt(5);
} ) ; # qr/^Illegal Operation \: There are no children to remove/, '... this should die';

# add a child now
$tree.addChild($TEST_SUB_TREE);

# giving no index argument for removeChildAt
dies-ok( {
 	$tree.removeChildAt(5);
} ) ; # qr/^Index Out of Bounds \: got \(5\) expected no more than \(1\)/, '... this should die';

is($tree.removeChildAt(0), $TEST_SUB_TREE, '... these should be the same');

# -----------------------------------------------
# exceptions for removeChild
# -----------------------------------------------

# giving no index argument for removeChild
dies-ok( {
 	$tree.removeChild();
} ) ; # qr/^Insufficient Arguments \: /, '... this should die';

# giving bad ref argument
dies-ok( {
 	$tree.removeChild([]);
} ) ; # qr/^Insufficient Arguments \: /, '... this should die';

# giving bad object argument
dies-ok( {
 	$tree.removeChild($BAD_OBJECT);
} ) ; # qr/^Insufficient Arguments \: /, '... this should die';

# giving bad object argument
dies-ok( {
 	$tree.removeChild($TEST_SUB_TREE);
} ) ; # qr/^Child Not Found \: /, '... this should die';

# -----------------------------------------------
# exceptions for *Sibling methods
# -----------------------------------------------

# attempting to add sibling to root trees
dies-ok( {
 	$tree.addSibling($TEST_SUB_TREE);
} ) ; # qr/^Insufficient Arguments \: cannot add a sibling to a ROOT tree/, '... this should die';

# attempting to add siblings to root trees
dies-ok( {
 	$tree.addSiblings($TEST_SUB_TREE);
} ) ; # qr/^Insufficient Arguments \: cannot add siblings to a ROOT tree/, '... this should die';

# attempting to insert sibling to root trees
dies-ok( {
 	$tree.insertSibling(0, $TEST_SUB_TREE);
} ) ; # qr/^Insufficient Arguments \: cannot insert sibling\(s\) to a ROOT tree/, '... this should die';

# attempting to insert sibling to root trees
dies-ok( {
 	$tree.insertSiblings(0, $TEST_SUB_TREE);
} ) ; # qr/^Insufficient Arguments \: cannot insert sibling\(s\) to a ROOT tree/, '... this should die';

# -----------------------------------------------
# exceptions for getChild
# -----------------------------------------------

# # not giving an index to the getChild method
dies-ok( {
 	$tree.getChild();
} ) ; # qr/^Insufficient Arguments \: Cannot get child without index/, '... this should die';

# -----------------------------------------------
# exceptions for getSibling
# -----------------------------------------------

# trying to get siblings of a root tree
dies-ok( {
 	$tree.getSibling();
} ) ; # qr/^Insufficient Arguments \: cannot get siblings from a ROOT tree/, '... this should die';

# trying to get siblings of a root tree
dies-ok( {
 	$tree.getAllSiblings();
} ) ; # qr/^Insufficient Arguments \: cannot get siblings from a ROOT tree/, '... this should die';

# -----------------------------------------------
# exceptions for traverse
# -----------------------------------------------

# passing no args to traverse
dies-ok( {
 	$tree.traverse();
} ) ; # qr/^Insufficient Arguments \: Cannot traverse without traversal function/, '... this should die';

# passing non-ref arg to traverse
dies-ok( {
 	$tree.traverse("Fail");
} ) ; # qr/^Incorrect Object Type \: traversal function is not a function/, '... this should die';

# passing non-code-ref arg to traverse
dies-ok( {
 	$tree.traverse($BAD_OBJECT);
} ) ; # qr/^Incorrect Object Type \: traversal function is not a function/, '... this should die';

# passing second non-ref arg to traverse
dies-ok( {
 	$tree.traverse(sub {}, "Fail");
} ) ; # qr/^Incorrect Object Type \: post traversal function is not a function/, '... this should die';

# passing second non-code-ref arg to traverse
dies-ok( {
 	$tree.traverse(sub {}, $BAD_OBJECT);
} ) ; # qr/^Incorrect Object Type \: post traversal function is not a function/, '... this should die';


# -----------------------------------------------
# exceptions for accept
# -----------------------------------------------

#todo have not implemented vistor class or methods
# passing no args to accept
#dies-ok( {
# 	$tree.accept();
#} ) ; # qr/^Insufficient Arguments \: You must supply a valid Visitor object/, '... this should die';

# # passing non-ref arg to accept
#dies-ok( {
# 	$tree.accept("Fail");
#} ) ; # qr/^Insufficient Arguments \: You must supply a valid Visitor object/, '... this should die';

# # passing non-object-ref arg to accept
#dies-ok( {
# 	$tree.accept([]);
#} ) ; # qr/^Insufficient Arguments \: You must supply a valid Visitor object/, '... this should die';

# # passing non-Tree::Simple::Visitor arg to accept
#dies-ok( {
# 	$tree.accept($BAD_OBJECT);
#} ) ; # qr/^Insufficient Arguments \: You must supply a valid Visitor object/, '... this should die';

# {
#     package TestPackage;
#     sub visit {}
# };

# # passing non-Tree::Simple::Visitor arg to accept
# lives_ok {
# 	$tree.accept(bless({}, "TestPackage"));
#} ) ; # '... but, this should live';

# # -----------------------------------------------
# # exceptions for setParent
# # -----------------------------------------------
#todo may remove setParent completely
# # if no parent is given
#dies-ok( {
# 	$tree.setParent();
#} ) ; # qr/^Insufficient Arguments/, '... this should croak';

# # if the parent that is given is not an object
#dies-ok( {
# 	$tree.setParent("Test");
#} ) ; # qr/^Insufficient Arguments/, '... this should croak';

# # if the parent that is given is a ref but not an object
#dies-ok( {
# 	$tree.setParent([]);
#} ) ; # qr/^Insufficient Arguments/, '... this should croak';

# # and if the parent that is given is an object but
# # is not a Tree::Simple object
#dies-ok( {
# 	$tree.setParent($BAD_OBJECT);
#} ) ; # qr/^Insufficient Arguments/, '... this should croak';

# -----------------------------------------------
# exceptions for setUID
# -----------------------------------------------

dies-ok( {
 	$tree.setUID();
} ) ; # qr/^Insufficient Arguments/, '... this should croak';

## ----------------------------------------------------------------------------
## end Exception Tests for Tree::Simple
## ----------------------------------------------------------------------------	
