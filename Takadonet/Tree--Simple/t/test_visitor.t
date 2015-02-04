use v6;
use Test;
plan 1;
BEGIN
{
    @*INC.push('lib');
    @*INC.push('blib');
}
use Tree::Simple;
use Tree::Simple::Visitor;
  
# create a visitor instance
my $visitor = Tree::Simple::Visitor.new();  							 

# create a tree to visit
my $tree = Tree::Simple.new($Tree::Simple::ROOT).addChildren(
        Tree::Simple.new("1.0"),
        Tree::Simple.new("2.0").addChild(
                    Tree::Simple.new("2.1.0")),
        Tree::Simple.new("3.0"));

# by default this will collect all the 
# node values in depth-first order into 
# our results


$visitor.setNodeFilter(sub ($t) { 
                return $t.getNodeValue();
                });  


$tree.accept($visitor);	  

# get our results and print them
my @results= <1.0 2.0 2.1.0 3.0>;


is($visitor.getResults().join(', '), @results.join(', '),'Find correct children');  # prints "1.0, 2.0, 2.1.0, 3.0" 


