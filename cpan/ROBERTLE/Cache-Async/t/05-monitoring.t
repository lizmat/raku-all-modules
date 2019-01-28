use Test;

use Cache::Async;

my $cache = Cache::Async.new(producer => 
    sub ($k) { 
        return "r$k"; 
    });

plan 25;

for 1..3 {
    for 1..7 -> $i {
        ok((await $cache.get(~$i)) eq "r$i", "cache-get works");
    }
}
my ($hits, $misses) = $cache.hits-misses;
is($misses, 7, "number of cache misses is as expected");
is($hits, 14, "number of cache hits is as expected");

($hits, $misses) = $cache.hits-misses;

is($misses, 0, "number of cache misses is reset by query");
is($hits, 0, "number of cache hits is reset y query");

done-testing;
