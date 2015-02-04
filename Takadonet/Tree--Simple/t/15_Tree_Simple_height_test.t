use v6;
use Test;
plan 66;
BEGIN
{
    @*INC.push('lib');
    @*INC.push('blib');
}

use Tree::Simple;



# test height (with pictures)
{    
    my $tree = Tree::Simple.new();
    ok($tree, Tree::Simple);

    my $D = Tree::Simple.new('D');
    ok($D, Tree::Simple);
    
    $tree.addChild($D);
    
    #   |
    #  <D>
    
    is($D.getHeight(), 1, '... D has a height of 1');
    
    my $E = Tree::Simple.new('E');
    ok($E, Tree::Simple);
    
    $D.addChild($E);
    
    #   |
    #  <D>
    #    \
    #    <E>
    
    is($D.getHeight(), 2, '... D has a height of 2');
    is($E.getHeight(), 1, '... E has a height of 1');
    
    my $F = Tree::Simple.new('F');
    ok($F, Tree::Simple);
    
    $E.addChild($F);
    
    #   |
    #  <D>
    #    \
    #    <E>
    #      \
    #      <F>
    
    is($D.getHeight(), 3, '... D has a height of 3');
    is($E.getHeight(), 2, '... E has a height of 2');
    is($F.getHeight(), 1, '... F has a height of 1');
    
    my $C = Tree::Simple.new('C');
    ok($C, Tree::Simple);
    
    $D.addChild($C);
    
    #    |
    #   <D>
    #   / \
    # <C> <E>
    #       \
    #       <F>
    
    is($D.getHeight(), 3, '... D has a height of 3');
    is($E.getHeight(), 2, '... E has a height of 2');
    is($F.getHeight(), 1, '... F has a height of 1');
    is($C.getHeight(), 1, '... C has a height of 1');
    
    my $B = Tree::Simple.new('B');
    ok($B, Tree::Simple);
    
    $C.addChild($B);
    
    #      |
    #     <D>
    #     / \
    #   <C> <E>
    #   /     \
    # <B>     <F>
    
    
    is($D.getHeight(), 3, '... D has a height of 3');
    is($E.getHeight(), 2, '... E has a height of 2');
    is($F.getHeight(), 1, '... F has a height of 1');
    is($C.getHeight(), 2, '... C has a height of 2');
    is($B.getHeight(), 1, '... B has a height of 1');
    
    my $A = Tree::Simple.new('A');
    ok($A, Tree::Simple);
    
    $B.addChild($A);
    
    #        |
    #       <D>
    #       / \
    #     <C> <E>
    #     /     \
    #   <B>     <F>
    #   /         
    # <A>         
    
    is($D.getHeight(), 4, '... D has a height of 4');
    is($E.getHeight(), 2, '... E has a height of 2');
    is($F.getHeight(), 1, '... F has a height of 1');
    is($C.getHeight(), 3, '... C has a height of 3');
    is($B.getHeight(), 2, '... B has a height of 2');
    is($A.getHeight(), 1, '... A has a height of 1');
    
    my $G = Tree::Simple.new('G');
    ok($G, Tree::Simple);

    #TODO need to make alias for 'insertChild' that direct to insertChildAt 
    $E.insertChildAt(0, $G);
    
    #        |
    #       <D>
    #       / \
    #     <C> <E>
    #     /   / \
    #   <B> <G> <F>
    #   /         
    # <A>         
    
    is($D.getHeight(), 4, '... D has a height of 4');
    is($E.getHeight(), 2, '... E has a height of 2');
    is($F.getHeight(), 1, '... F has a height of 1');
    is($G.getHeight(), 1, '... G has a height of 1');
    is($C.getHeight(), 3, '... C has a height of 3');
    is($B.getHeight(), 2, '... B has a height of 2');
    is($A.getHeight(), 1, '... A has a height of 1');
    
    my $H = Tree::Simple.new('H');
    ok($H, Tree::Simple);
    
    $G.addChild($H);
    
    #        |
    #       <D>
    #       / \
    #     <C> <E>
    #     /   / \
    #   <B> <G> <F>
    #   /     \    
    # <A>     <H>    
    
    is($D.getHeight(), 4, '... D has a height of 4');
    is($E.getHeight(), 3, '... E has a height of 3');
    is($F.getHeight(), 1, '... F has a height of 1');
    is($G.getHeight(), 2, '... G has a height of 2');
    is($H.getHeight(), 1, '... H has a height of 1');
    is($C.getHeight(), 3, '... C has a height of 3');
    is($B.getHeight(), 2, '... B has a height of 2');
    is($A.getHeight(), 1, '... A has a height of 1');

    ok($B.removeChild($A), '... removed A subtree from B tree');

    #        |
    #       <D>
    #       / \
    #     <C> <E>
    #     /   / \
    #   <B> <G> <F>
    #         \    
    #         <H> 

    is($D.getHeight(), 4, '... D has a height of 4');
    is($E.getHeight(), 3, '... E has a height of 3');
    is($F.getHeight(), 1, '... F has a height of 1');
    is($G.getHeight(), 2, '... G has a height of 2');
    is($H.getHeight(), 1, '... H has a height of 1');
    is($C.getHeight(), 2, '... C has a height of 2');
    is($B.getHeight(), 1, '... B has a height of 1');
    
    # and the removed tree is ok
    is($A.getHeight(), 1, '... A has a height of 1');
    
    ok($D.removeChild($E), '... removed E subtree from D tree');

    #        |
    #       <D>
    #       / 
    #     <C> 
    #     /     
    #   <B>

    is($D.getHeight(), 3, '... D has a height of 3');
    is($C.getHeight(), 2, '... C has a height of 2');
    is($B.getHeight(), 1, '... B has a height of 1');
    
    # and the removed trees are ok
    is($E.getHeight(), 3, '... E has a height of 3');
    is($F.getHeight(), 1, '... F has a height of 1');
    is($G.getHeight(), 2, '... G has a height of 2');
    is($H.getHeight(), 1, '... H has a height of 1');    
    
    ok($D.removeChild($C), '... removed C subtree from D tree');

    #        |
    #       <D>

    is($D.getHeight(), 1, '... D has a height of 1');
    
    # and the removed tree is ok
    is($C.getHeight(), 2, '... C has a height of 2');
    is($B.getHeight(), 1, '... B has a height of 1');      

}
