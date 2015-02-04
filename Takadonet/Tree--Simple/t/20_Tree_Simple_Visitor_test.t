use v6;
use Test;
plan 35;
BEGIN
{
    @*INC.push('lib');
    @*INC.push('blib');
}
use Tree::Simple;
use Tree::Simple::Visitor;

#todo do not like that have to put a signature here... should be allow to have anything
my $SIMPLE_SUB = sub (*@a) { "test sub" };

# -----------------------------------------------
# test the new style interface
# -----------------------------------------------

my $visitor = Tree::Simple::Visitor.new();
ok($visitor ~~ Tree::Simple::Visitor);

my $tree = Tree::Simple.new($Tree::Simple::ROOT).addChildren(
 							Tree::Simple.new("1").addChildren(
                                             Tree::Simple.new("1.1"),
                                             Tree::Simple.new("1.2").addChild(Tree::Simple.new("1.2.1")),
                                             Tree::Simple.new("1.3")                                            
                                         ),
 							Tree::Simple.new("2"),
 							Tree::Simple.new("3"),							
 					   );
ok($tree ~~ Tree::Simple);

$tree.accept($visitor);

ok $visitor.can('getResults'),"Can do getResults";

is_deeply([ $visitor.getResults() ], [ <1 1.1 1.2 1.2.1 1.3 2 3>],
         '... got what we expected');

ok($visitor.can('setNodeFilter'));

my $node_filter = sub (*@x) { return "_" ~ @x[0].getNodeValue() };
$visitor.setNodeFilter($node_filter);

ok($visitor.can('getNodeFilter'));
is($visitor.getNodeFilter(), "$node_filter", '... got back what we put in');

# visit the tree again to get new results now
$tree.accept($visitor);

is_deeply($visitor.getResults(),[ <_1 _1.1 _1.2 _1.2.1 _1.3 _2 _3>],
         '... got what we expected');
        
# test some exceptions
dies_ok ({
     $visitor.setNodeFilter();        
});

dies_ok ({
     $visitor.setNodeFilter([]);        
});

# -----------------------------------------------
# test the old style interface for backwards 
# compatability
# -----------------------------------------------

# and that our RECURSIVE constant is properly defined
is($Tree::Simple::Visitor::RECURSIVE, 'RECURSIVE');
# and that our CHILDREN_ONLY constant is properly defined
is($Tree::Simple::Visitor::CHILDREN_ONLY, 'CHILDREN_ONLY');

# no depth
my $visitor1 = Tree::Simple::Visitor.new($SIMPLE_SUB);
ok($visitor1 ~~ Tree::Simple::Visitor);

# children only
my $visitor2 = Tree::Simple::Visitor.new($SIMPLE_SUB, $Tree::Simple::Visitor::CHILDREN_ONLY);
ok($visitor2 ~~ Tree::Simple::Visitor);

# recursive
my $visitor3 = Tree::Simple::Visitor.new($SIMPLE_SUB, $Tree::Simple::Visitor::RECURSIVE);
ok($visitor3 ~~ Tree::Simple::Visitor);

# -----------------------------------------------
# test constructor exceptions
# -----------------------------------------------

# we pass a bad depth (string)
dies_ok ({
    my $test = Tree::Simple::Visitor.new($SIMPLE_SUB, "Fail")
});
   
# we pass a bad depth (numeric)
dies_ok ({
my $test = Tree::Simple::Visitor.new($SIMPLE_SUB, 100);
});

# we pass a non-ref func argument
dies_ok ({
 	my $test = Tree::Simple::Visitor.new("Fail");
});


# # we pass a non-code-ref func arguement   
dies_ok ({
 	my $test = Tree::Simple::Visitor.new([]);
});



# -----------------------------------------------
# test other exceptions
# -----------------------------------------------

# and make sure we can call the visit method
ok($visitor1.can('visit'));

# test no arg
dies_ok ( {
 	$visitor1.visit();
});

#    '... we are expecting this error'; 
   
# test non-ref arg
dies_ok ( {
 	$visitor1.visit("Fail");
});

#    '... we are expecting this error'; 	 
   
# test non-object ref arg
dies_ok ( {
 	$visitor1.visit([]);
 });

class BAD {};

my $BAD_OBJECT = BAD.new();   
   
# test non-Tree::Simple object arg
dies_ok ( {
 	$visitor1.visit($BAD_OBJECT);
});

# -----------------------------------------------
# Test accept & visit
# -----------------------------------------------
# Note: 
# this test could be made more robust by actually
# getting results and testing them from the 
# Visitor object. But for right now it is good
# enough to have the code coverage, and know
# all the peices work.
# -----------------------------------------------

# now make a tree
my $tree1 = Tree::Simple.new($Tree::Simple::ROOT).addChildren(
							Tree::Simple.new("1.0"),
							Tree::Simple.new("2.0"),
							Tree::Simple.new("3.0"),							
					   );
ok($tree1 ~~ Tree::Simple);

is($tree1.getChildCount(), 3, '... there are 3 children here');

#and pass the visitor1 to accept
lives_ok( {
 	$tree1.accept($visitor1);
}, '.. this passes fine');

# and pass the visitor2 to accept
lives_ok( {
 	$tree1.accept($visitor2);
}, '.. this passes fine');

# and pass the visitor3 to accept
lives_ok( {
	$tree1.accept($visitor3);
}, '.. this passes fine');

# ----------------------------------------------------
# test some misc. weirdness to get the coverage up :P
# ----------------------------------------------------

# check that includeTrunk works as we expect it to
{
     my $visitor = Tree::Simple::Visitor.new();
     ok(!$visitor.includeTrunk(), '... this should be false right now');

     $visitor.includeTrunk(Bool::True);
     
     is($visitor.includeTrunk(), Bool::True, '... this should be true now');

     $visitor.includeTrunk(Mu);
     is($visitor.includeTrunk(), Bool::True , '... this should be true still');
    
     $visitor.includeTrunk("");
     is($visitor.includeTrunk(), Bool::False , '... this should be false again');
}

# check that clearNodeFilter works as we expect it to
{
     my $visitor = Tree::Simple::Visitor.new();
    
     my $filter = sub { "filter" };
    
     $visitor.setNodeFilter($filter);
     is($visitor.getNodeFilter(), $filter, 'our node filter is set correctly');
    
     $visitor.clearNodeFilter();
     ok(! defined($visitor.getNodeFilter()), '... our node filter has now been undefined'); 
}


