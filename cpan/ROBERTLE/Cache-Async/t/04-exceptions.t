use Test;

use Cache::Async;

my $cache = Cache::Async.new(producer => 
    sub ($k) { 
        if $k <= 0 {
            die "invalid key";
        } 
        else {
            return "r$k"; 
        }
    });

plan 3;

ok((await $cache.get("1")) eq 'r1', "non-throwing cache get works");
dies-ok({ await $cache.get("0") }, "exceptions get propagated");

my $cache2 = Cache::Async.new(producer => sub ($k) {
        Promise.in(1).then({ die "woot"})
    });

dies-ok({ await $cache2.get("?") }, "exceptions get propagated from promise-returning producer");

done-testing;
