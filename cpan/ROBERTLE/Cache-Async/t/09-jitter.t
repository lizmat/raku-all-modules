use Test;

use Cache::Async;

plan 2;

sub measure-jitter($cache) {
    my $start = DateTime.now.utc;
    my $v;
    for ^42 {
        $v = await $cache.get("A");
        sleep(.1);
    }
    my $measured-jitter = ($v - $start);
    $measured-jitter = abs($measured-jitter - 4.0); # 4.0 is the expected value with no jitter
    diag "measured jitter is $measured-jitter";
    return $measured-jitter;
}

my $cache = Cache::Async.new(max-age => Duration.new(.25), 
    producer => sub ($k) {
        DateTime.now.utc; 
});
ok(measure-jitter($cache) < .08, "jitter in default cache should be low"); 

my $jittery-cache = Cache::Async.new(max-age => Duration.new(.5), jitter => Duration.new(.4),
    producer => sub ($k) {
        DateTime.now.utc; 
});
ok(measure-jitter($jittery-cache) > .12, "configured jitter in cache should be measurably high"); 

done-testing;
