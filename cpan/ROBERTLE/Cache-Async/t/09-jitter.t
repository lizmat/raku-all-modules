use Test;

use Cache::Async;

plan 2;

sub measure-jitter($cache) {
    my $avg-jitter = 0;
    my @ids = ('A', 'B', 'C', 'D', 'E');
    for @ids -> $id {
        my $start = DateTime.now.utc;
        my $v;
        for ^42 {
            $v = await $cache.get($id);
            sleep(.1);
        }
        my $measured-jitter = ($v - $start);
        $measured-jitter = abs($measured-jitter - 4.0); # 4.0 is the expected value with no jitter
        diag "measured jitter is $measured-jitter";
        $avg-jitter += $measured-jitter;
    }
    return $avg-jitter / @ids.elems;;
}

my $cache = Cache::Async.new(max-age => Duration.new(.25), 
    producer => sub ($k) {
        DateTime.now.utc; 
});
ok(measure-jitter($cache) < .1, "jitter in default cache should be low"); 

my $jittery-cache = Cache::Async.new(max-age => Duration.new(.5), jitter => Duration.new(.45),
    producer => sub ($k) {
        DateTime.now.utc; 
});
ok(measure-jitter($jittery-cache) > .15, "configured jitter in cache should be measurably high"); 

done-testing;
