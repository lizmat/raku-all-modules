use Test;

use Cache::Async;

my $trace = "";
my $trace-lock = Lock.new;

my $cache = Cache::Async.new(producer => sub ($k) { sleep 0.1; $trace-lock.protect({ $trace = $trace ~ $k}); return "[$k]"; });

plan 3;

my $pa = $cache.get('a');
my $pb = $cache.get('b');
$trace-lock.protect({$trace = $trace ~ '0'});

ok((await $pa) eq "[a]", "cache returned expected result for key a");
ok((await $pb) eq "[b]", "cache returned expected result for key b");

ok($trace eq "0ba" || $trace eq "0ab", "cache gets returned with futures before they were fullfilled");

done-testing;
