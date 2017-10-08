use v6;
use Test;
use Router::Boost;

subtest {
    my $r = Router::Boost.new();
    dies-ok { $r.add('/blog/{id:(\d+)}', 'dispatch_month') };
}, 'Capture paren is exist';

subtest {
    my $r = Router::Boost.new();
    lives-ok { $r.add('/blog/{id:[\d+]}', 'dispatch_month') };
}, 'Capture paren is not exist';

done-testing;

