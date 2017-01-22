use v6;
use Test;

use-ok 'Algorithm::Treap';
use Algorithm::Treap;

{
    dies-ok { my $treap = Algorithm::Treap[Any].new; }, "It should handle Str or Int nodes";
}

{
    dies-ok { my $treap = Algorithm::Treap[Str].new(order-by => Any); }, "It shouldn't handle a type object";
}

{
    dies-ok { my $treap = Algorithm::Treap[Str].new(order-by => 'asc'); }, "It should handle a Str";
}

{
    lives-ok { my $treap = Algorithm::Treap[Str].new(order-by => TOrder::ASC); }, "It should handle TOrder::ASC or TOrder::DESC";
}

done-testing;
