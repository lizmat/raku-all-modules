use Test;

use Cache::Async;

my $cache = Cache::Async.new(refresh-after => Duration.new(.25), producer => sub ($k) {
   return DateTime.now.utc; 
});

plan 10;

for 1..10 {
    my $now = DateTime.now.utc;
    my $c = await $cache.get('A');
    my $age = $now - $c;
    ok($age < .5, "Cache entry should never be older than .5s");
    sleep .1;
}

done-testing;
