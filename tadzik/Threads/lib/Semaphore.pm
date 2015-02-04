use Threads;

class Semaphore {
    has $.value;

    method wait {
        async(sub {
            loop {
                pir::disable_preemption__0;
                if $!value > 0 {
                    $!value--;
                    last;
                }
                pir::enable_preemption__0;
                pir::pass__0();
                1;
            }
            pir::enable_preemption__0;
            return;
        }).join;
    }

    method post {
        async(sub {
            pir::disable_preemption__0;
            $!value++;
            pir::enable_preemption__0;
            return;
        }).join
    }
}
