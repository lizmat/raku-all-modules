use v6;
use Test;
plan 76;
BEGIN
{
    @*INC.push('lib');
    @*INC.push('blib');
}

use Tree::Simple;

{ # test height (with pictures)
    
    my $tree = Tree::Simple.new();
    isa_ok($tree, Tree::Simple);

    
    my $D = Tree::Simple.new('D');
    isa_ok($D, Tree::Simple);    

    
    $tree.addChild($D);
    
    #   |
    #  <D>
    
    is($D.getWidth(), 1, '... D has a width of 1');
    
    my $E = Tree::Simple.new('E');
    isa_ok($E, Tree::Simple);
    
    $D.addChild($E);
    
    #   |
    #  <D>
    #    \
    #    <E>
    
    is($D.getWidth(), 1, '... D has a width of 1');
    is($E.getWidth(), 1, '... E has a width of 1');
    
    my $F = Tree::Simple.new('F');
    isa_ok($F, Tree::Simple);
    
    $E.addChild($F);
    
    #   |
    #  <D>
    #    \
    #    <E>
    #      \
    #      <F>
    
    is($D.getWidth(), 1, '... D has a width of 1');
    is($E.getWidth(), 1, '... E has a width of 1');
    is($F.getWidth(), 1, '... F has a width of 1');
    
    my $C = Tree::Simple.new('C');
    isa_ok($C, Tree::Simple);
    
    $D.addChild($C);
    
    #    |
    #   <D>
    #   / \
    # <C> <E>
    #       \
    #       <F>
    
    is($D.getWidth(), 2, '... D has a width of 2');
    is($E.getWidth(), 1, '... E has a width of 1');
    is($F.getWidth(), 1, '... F has a width of 1');
    is($C.getWidth(), 1, '... C has a width of 1');
    
    my $B = Tree::Simple.new('B');
    isa_ok($B, Tree::Simple);
    
    $D.addChild($B);
    
    #        |
    #       <D>
    #      / | \
    #   <B> <C> <E>
    #             \
    #             <F>
    
    
    is($D.getWidth(), 3, '... D has a width of 3');
    is($E.getWidth(), 1, '... E has a width of 1');
    is($F.getWidth(), 1, '... F has a width of 1');
    is($C.getWidth(), 1, '... C has a width of 1');
    is($B.getWidth(), 1, '... B has a width of 1');
        
    
    my $A = Tree::Simple.new('A');
    isa_ok($A, Tree::Simple);
    
    $E.addChild($A);
    
    #        |
    #       <D>
    #      / | \
    #   <B> <C> <E>
    #           / \
    #         <A> <F>       
    
    is($D.getWidth(), 4, '... D has a width of 4');
    is($E.getWidth(), 2, '... E has a width of 2');
    is($F.getWidth(), 1, '... F has a width of 1');
    is($C.getWidth(), 1, '... C has a width of 1');
    is($B.getWidth(), 1, '... B has a width of 1');
    is($A.getWidth(), 1, '... A has a width of 1');
    
    my $G = Tree::Simple.new('G');
    isa_ok($G, Tree::Simple);
    #TODO need to make alias for 'insertChild' that direct to insertChildAt 
    $E.insertChildAt(1, $G);
    
    #        |
    #       <D>
    #      / | \
    #   <B> <C> <E>
    #          / | \
    #       <A> <G> <F>         
    
    is($D.getWidth(), 5, '... D has a width of 5');
    is($E.getWidth(), 3, '... E has a width of 3');
    is($F.getWidth(), 1, '... F has a width of 1');
    is($G.getWidth(), 1, '... G has a width of 1');
    is($C.getWidth(), 1, '... C has a width of 1');
    is($B.getWidth(), 1, '... B has a width of 1');
    is($A.getWidth(), 1, '... A has a width of 1');
    
    my $H = Tree::Simple.new('H');
    isa_ok($H, Tree::Simple);
    
    $G.addChild($H);
    
    #        |
    #       <D>
    #      / | \
    #   <B> <C> <E>
    #          / | \
    #       <A> <G> <F> 
    #            |
    #           <H>    
    
    is($D.getWidth(), 5, '... D has a width of 5');
    is($E.getWidth(), 3, '... E has a width of 3');
    is($F.getWidth(), 1, '... F has a width of 1');
    is($G.getWidth(), 1, '... G has a width of 1');
    is($H.getWidth(), 1, '... H has a width of 1');
    is($C.getWidth(), 1, '... C has a width of 1');
    is($B.getWidth(), 1, '... B has a width of 1');
    is($A.getWidth(), 1, '... A has a width of 1');
    
    my $I = Tree::Simple.new('I');
    isa_ok($I, Tree::Simple);
    
    $G.addChild($I);
    
    #        |
    #       <D>
    #      / | \
    #   <B> <C> <E>
    #          / | \
    #       <A> <G> <F> 
    #            | \
    #           <H> <I>   
    
    is($D.getWidth(), 6, '... D has a width of 6');
    is($E.getWidth(), 4, '... E has a width of 4');
    is($F.getWidth(), 1, '... F has a width of 1');
    is($G.getWidth(), 2, '... G has a width of 2');
    is($H.getWidth(), 1, '... H has a width of 1');
    is($I.getWidth(), 1, '... I has a width of 1');    
    is($C.getWidth(), 1, '... C has a width of 1');
    is($B.getWidth(), 1, '... B has a width of 1');
    is($A.getWidth(), 1, '... A has a width of 1');      

    ok($E.removeChild($A), '... removed A subtree from B tree');

    #        |
    #       <D>
    #      / | \
    #   <B> <C> <E>
    #            | \
    #           <G> <F> 
    #            | \
    #           <H> <I>  

    is($D.getWidth(), 5, '... D has a width of 5');
    is($E.getWidth(), 3, '... E has a width of 3');
    is($F.getWidth(), 1, '... F has a width of 1');
    is($G.getWidth(), 2, '... G has a width of 2');
    is($H.getWidth(), 1, '... H has a width of 1');
    is($C.getWidth(), 1, '... C has a width of 2');
    is($B.getWidth(), 1, '... B has a width of 1');
    
    # and the removed tree is ok
    is($A.getWidth(), 1, '... A has a width of 1');
    
    ok($D.removeChild($E), '... removed E subtree from D tree');

    #        |
    #       <D>
    #      / | 
    #   <B> <C>

    is($D.getWidth(), 2, '... D has a width of 2');
    is($C.getWidth(), 1, '... C has a width of 1');
    is($B.getWidth(), 1, '... B has a width of 1');
    
    # and the removed trees are ok
    is($E.getWidth(), 3, '... E has a width of 3');
    is($F.getWidth(), 1, '... F has a width of 1');
    is($G.getWidth(), 2, '... G has a width of 2');
    is($H.getWidth(), 1, '... H has a width of 1');    
    
    ok($D.removeChild($C), '... removed C subtree from D tree');

    #        |
    #       <D>
    #      /  
    #   <B> 

    is($D.getWidth(), 1, '... D has a width of 1');
    is($B.getWidth(), 1, '... B has a width of 1');
    
    # and the removed tree is ok
    is($C.getWidth(), 1, '... C has a width of 1');
      
}
