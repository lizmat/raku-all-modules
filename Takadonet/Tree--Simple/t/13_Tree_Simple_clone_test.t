use v6;
use Test;
plan 48;
BEGIN
{
    @*INC.push('lib');
    @*INC.push('blib');
}

use Tree::Simple;

## ----------------------------------------------------------------------------
# NOTE:
# This specifically tests the details of the cloning functions
## ----------------------------------------------------------------------------

my $tree = Tree::Simple.new($Tree::Simple::ROOT);
ok($tree ~~ Tree::Simple);

my $test = "test";

my $SCALAR_REF = \$test;
my $REF_TO_REF = \$SCALAR_REF;
my $ARRAY_REF = [ 1, 2, 3, 4 ];
my $HASH_REF = { one => 1, two => 2 };
my $CODE_REF = sub { "code ref test" };
my $SUB_TREE = Tree::Simple.new("sub tree test");
class Misc { has $.name;};
my $MISC_OBJECT = Misc.new(name => "Misc");
my $REGEX_REF = rx/^hello\sworld$/;
$tree.addChildren(

 		Tree::Simple.new("non-ref"),	
 		Tree::Simple.new($SCALAR_REF),	
 		Tree::Simple.new($ARRAY_REF),
 		Tree::Simple.new($HASH_REF),
 		Tree::Simple.new($CODE_REF),
 		Tree::Simple.new($REGEX_REF),
 		Tree::Simple.new($MISC_OBJECT),
 		Tree::Simple.new($SUB_TREE),
     		Tree::Simple.new($REF_TO_REF)        ,
		);

my $clone = $tree.clone();
ok($clone ~~Tree::Simple);

# make sure all the parentage is correct
is($clone.getParent(), $Tree::Simple::ROOT, '... the clones parent is a root');

for ($clone.getAllChildren()) -> $child {
    is($child.getParent(), $clone, '... the clones childrens parent should be our clone');
}

isnt($clone.WHICH, $tree.WHICH, '... these should be refs');

is($clone.getChild(0).getNodeValue(), $tree.getChild(0).getNodeValue(), '... these should be the same value');

# they should both be scalar refs
ok($clone.getChild(1).getNodeValue().WHAT ~~ Capture, '... these should be scalar refs');
ok($tree.getChild(1).getNodeValue().WHAT ~~ Capture, '... these should be scalar refs');
# but different ones based on their memory address
isnt($clone.getChild(1).getNodeValue().WHERE, $tree.getChild(1).getNodeValue().WHERE, 
 	'... these should be different scalar refs');
#with the same value
is($clone.getChild(1).getNodeValue().[0], $tree.getChild(1).getNodeValue().[0], 
 	'... these should be the same value');
	
# they should both be array refs
is($clone.getChild(2).getNodeValue().WHAT, Array, '... these should be array refs');
is($tree.getChild(2).getNodeValue().WHAT, Array, '... these should be array refs');
# but different ones based on their memory address
isnt($clone.getChild(2).getNodeValue().WHERE, $tree.getChild(2).getNodeValue().WHERE, 
 	'... these should be different array refs');	
# with the same value	
is_deeply(
    $clone.getChild(2).getNodeValue(), 
    $tree.getChild(2).getNodeValue(), 
	'... these should have the same contents');
	
# they should both be hash refs
is($clone.getChild(3).getNodeValue().WHAT, Hash, '... these should be hash refs');
is($tree.getChild(3).getNodeValue().WHAT, Hash, '... these should be hash refs');
#but different ones based on their memory address
isnt($clone.getChild(3).getNodeValue().WHERE, $tree.getChild(3).getNodeValue().WHERE, 
 	'... these should be different hash refs');	
# with the same value	
is_deeply(
     $clone.getChild(3).getNodeValue(), 
     $tree.getChild(3).getNodeValue(), 
	'... these should have the same contents');	

# they should both be code refs
#perhaps should look if it's a 'sub' then 'Code'? Will change it to sub for now
is($clone.getChild(4).getNodeValue().WHAT, Sub, '... these should be sub refs');
is($tree.getChild(4).getNodeValue().WHAT, Sub, '... these should be sub refs');
# and still the same
is($clone.getChild(4).getNodeValue(), $tree.getChild(4).getNodeValue(), 
 	'... these should be the same code refs');	
is($clone.getChild(4).getNodeValue().(), $CODE_REF.(), '... this is equal');

# they should both be reg-ex refs
is($clone.getChild(5).getNodeValue().WHAT, Regex, '... these should be reg-ex refs');
is($tree.getChild(5).getNodeValue().WHAT, Regex, '... these should be reg-ex refs');
# and still the same
is($clone.getChild(5).getNodeValue(), $tree.getChild(5).getNodeValue(), 
	'... these should be the same reg-ex refs');	
	
# they should both be misc object refs
is($clone.getChild(6).getNodeValue().WHAT, Misc, '... these should be misc object refs');
is($tree.getChild(6).getNodeValue().WHAT, Misc, '... these should be misc object refs');
# and still the same since it does not have a clone function
is($clone.getChild(6).getNodeValue().WHERE, $tree.getChild(6).getNodeValue().WHERE, 
	'... these should be the same misc object refs');	
	
# they should both be Tree::Simple objects
is($clone.getChild(7).getNodeValue().WHAT, Tree::Simple, '... these should be Tree::Simple');
is($tree.getChild(7).getNodeValue().WHAT, Tree::Simple, '... these should be Tree::Simple');
# but different ones
isnt($clone.getChild(7).getNodeValue().WHERE, $tree.getChild(7).getNodeValue().WHERE, 
	'... these should be different Tree::Simple objects');	
# with the same value	
is($clone.getChild(7).getNodeValue().getNodeValue(), $tree.getChild(7).getNodeValue().getNodeValue(), 
	'... these should have the same contents');	
    
# they should both be scalar refs
#todo not sure what I should be testing against.. believe Capture
is($clone.getChild(8).getNodeValue().WHAT, Capture, '... these should be refs of refs');
is($tree.getChild(8).getNodeValue().WHAT, Capture, '... these should be refs of refs');
# but different ones 
isnt($clone.getChild(8).getNodeValue().WHERE, $tree.getChild(8).getNodeValue().WHERE, 
	'... these should be different scalar refs');
# with the same ref value
is($clone.getChild(8).getNodeValue().[0].[0], $tree.getChild(8).getNodeValue().[0].[0], 
 	'... these should be the same value');    

# test cloneShallow

my $shallow_clone = $tree.cloneShallow();

isnt($shallow_clone.WHICH, $tree.WHICH, '... these should be refs');

is_deeply(
 		 $shallow_clone.getAllChildren() ,
 		 $tree.getAllChildren() ,
		'... the children are the same');
		
my $sub_tree = $tree.getChild(7);
my $sub_tree_clone = $sub_tree.cloneShallow();
# but different ones
isnt($sub_tree_clone.getNodeValue().WHERE, $sub_tree.getNodeValue().WHERE, 
 	'... these should be different Tree::Simple objects');		
# with the same value	
is($sub_tree_clone.getNodeValue().getNodeValue(), $sub_tree.getNodeValue().getNodeValue(), 
	'... these should have the same contents');	

