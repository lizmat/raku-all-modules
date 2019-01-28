use Test;

use Cache::Async;

my $cache = Cache::Async.new(producer => sub ($k) {  
        Promise.in(1).then({"delayed $k"})
    });

plan 1;

is((await $cache.get("X")), 'delayed X', "cache with async producer produces correct result");

done-testing;
