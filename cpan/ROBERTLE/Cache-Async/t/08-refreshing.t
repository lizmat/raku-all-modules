use Test;

use Cache::Async;

my $cache = Cache::Async.new(refresh-after => Duration.new(.125), producer => sub ($k) {
   return DateTime.now.utc; 
});

plan 10;

for 1..10 {
    my $now = DateTime.now.utc;
    my $c = await $cache.get('A');
    my $age = $now - $c;
    ok($age < .25, "Cache entry should never be older than .25s");
    sleep .05;
}

done-testing;
