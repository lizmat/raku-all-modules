use v6;
use Rakudo::Slippy::Semilist;

my sub slow($n, $m){ 
    sleep 5;
    $n * $m
}

sub is-cached(&slow){
    my %cache;
    
    my $wrap-handle = &slow.wrap(sub (|c) {
        %cache{||c.Array} = callsame unless %cache{||c.Array}:exists;
        %cache{||c.Array}
    });

    return-rw $wrap-handle, %cache
}

sub bench(&c, :$repeat = 1){
    my $t = now;
    my $r;
    loop (my int $i = 1;$i <= $repeat; $i++){
        $r = c;
    }
    $r, (now - $t) / $repeat;
}

my \cache = is-cached(&slow)[1];
say &slow.assuming(3, 14).&bench[1];
say &slow.assuming(3, 14).&bench(:repeat(100000))[1];

dd cache, cache{3;14}:exists;

