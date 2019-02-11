use Test;

use Cache::Async;

my %producer-count;

my $cache = Cache::Async.new(producer => sub ($k) { my $i = %producer-count{$k}++; return "$k/$i"; });

plan 12;

ok(sum(%producer-count.values) == 0, "no initial producer state");

$cache.put('X', '??');
ok((await $cache.get("X")) eq '??', "previously put' content returned");
ok(%producer-count{'X'}//0 == 0, "X not produced, already in cache");

await $cache.get("Y");
ok(%producer-count{'Y'}//0 == 1, "Y produced on first call");
ok((await $cache.get("Y")) ~~ /'Y/' <digit>/, "returned content matches producer output");
ok(%producer-count{'Y'}//0 == 1, "Y not re-produced on second call");

ok((await $cache.get(123)) eq "123/0", "Can get for a numeric key");

dies-ok({ Cache::Async.new(jitter => Duration.new(.2)) }, "c'tor with jitter but no max-age dies");
dies-ok({ Cache::Async.new(jitter => Duration.new(2), max-age => Duration.new(1)) }, 
    "c'tor with jitter > max-age dies");
dies-ok({ Cache::Async.new(jitter => Duration.new(2), refresh-after => Duration.new(1)) }, 
    "c'tor with jitter > refresh-after dies");
dies-ok({ Cache::Async.new(max-age => Duration.new(1), refresh-after => Duration.new(2)) }, 
    "c'tor with refresh-after > max-age dies");
lives-ok({ Cache::Async.new(max-age => Duration.new(3), refresh-after => Duration.new(2)), 
    jitter => Duration.new(1) }, 
    "c'tor with jitter < refresh-after < max-age does not die");

done-testing;
