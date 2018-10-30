use v6;
use Test;
use Context;

class Foo { has Int $.i; has Str $.s; } # For testing.

subtest {
    lives-ok {
        my $c = Context.new();
        my $canceler = $c.canceler();
    }, 'basic';
}, 'construct';

subtest {
    lives-ok {
        my $c = Context.new();
        $c.set('a','b');
        $c.set('c','d',sub (Str $s --> Str) { return $s.clone; });
        my $a-v = $c.get('a');
        is ($a-v eq 'b'), True, 'val match';
        my $c-v = $c.get('c');
        is ($c-v eq 'd'), True, 'val match';
    }, 'set/get scalar';

    dies-ok {
        my $c = Context.new();
        $c.set('a','b');
        $c.set('c','d',sub (Int $s --> Int) { return $s.clone; });
        my $a-v = $c.get('a');
        is ($a-v eq 'b'), True, 'val match';
        my $c-v = $c.get('c');
        is ($c-v eq 'd'), True, 'val match';
    }, 'set/get scalar bad copy function';

    lives-ok {
        my $cp = sub (Foo $f --> Foo) { Foo.new(i => $f.i, s => $f.s); }
        my Foo $k = Foo.new(i => 3, s => 'k');
        my Foo $v = Foo.new(i => 5, s => 'v');        
        my $c = Context.new();
        $c.set($k,$v,$cp); 
        my Foo $k-v = $c.get($k);
        is ($k-v eqv $v), True, 'val match';
    }, 'set/get complex type';

    dies-ok {
        my $cp = sub (Int $f --> Int) { $f.clone; }
        my Foo $k = Foo.new(i => 3, s => 'k');
        my Foo $v = Foo.new(i => 5, s => 'v');        
        my $c = Context.new();
        $c.set($k,$v,$cp); 
        my Foo $k-v = $c.get($k);
        is ($k-v eqv $v), True, 'val match';
    }, 'set/get complex type bad copy function';
}, 'set/get';

subtest {
    lives-ok {
        my $c = Context.new();
        try {
            my $r = $c.get('a');
            CATCH {
                when X::Context::KeyNotFound {}
            }
        }
    }, 'caught exception for missing key lookup';

    dies-ok {
        my $c = Context.new();
        my $r = $c.get('a');
    }, 'uncaught exception for missing key lookup';
}, 'missing keys';

subtest {
    lives-ok {
        my $c = Context.new();
        my $cancel = $c.canceler();
        my Int $t = 0;
        
        my $p = start {
            sub (Context $ctx) {
                my $supply = $ctx.supplier.Supply;
                my $pf = start {
                    react {
                        whenever $supply -> $v { 
                            if $v eq $CONTEXT_CANCEL {
                                $t = 1;
                                done;                    
                            }
                        }
                    }
                }
                await $pf;
            }($c);
        }

        start {
            sleep 0.5;
            $cancel();
        }
        await $p;

        is ($t == 1), True, 'val match';
    }
}, 'context cancel';

subtest {
    lives-ok {
        my $c = Context.new();
        my $timeout = $c.timeout(1);
        my Int $t = 0;
        
        my $p = start {
            sub (Context $ctx) {
                my $supply = $ctx.supplier.Supply;
                my $pf = start {
                    react {
                        whenever $supply -> $v { 
                            if $v eq $CONTEXT_CANCEL {
                                $t = 1;
                                done;                    
                            }
                        }
                    }
                }
                await $pf;
            }($c);
        }

        my ($before,$after);
        
        my $x = start {
            $before = now.to-posix()[0];
            $timeout();
            $after = now.to-posix()[0];
        }
        await $p;
        await $x;

        my $duration = $after - $before;
        
        is ($t == 1), True, 'val match';
        is (($duration >= 1.0) && ($duration <= 1.1)), True, 'timeout duration';
    }
}, 'timeout cancel';

done-testing;
