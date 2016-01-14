class Concurrent::Iterator does Iterator {
    has $!target-iterator;
    has $!lock;
    has int $!reached-end = 0;
    has $!exception;

    method new(Iterable:D $target) {
        self.bless(:$target)
    }

    submethod BUILD(:$target) {
        $!target-iterator = $target.iterator;
        $!lock = Lock.new;
    }

    method pull-one() {
        $!lock.protect: {
            if $!reached-end {
                IterationEnd
            }
            elsif $!exception {
                $!exception.rethrow
            }
            else {
                my \pulled = $!target-iterator.pull-one;
                CATCH { $!exception = $_ }
                $!reached-end = 1 if pulled =:= IterationEnd;
                pulled
            }
        }
    }
}

proto concurrent-iterator($) is export { * }
multi concurrent-iterator(Iterable:D \iterable) {
    Concurrent::Iterator.new(iterable)
}
multi concurrent-iterator($other) {
    concurrent-iterator($other.list)
}

sub concurrent-seq($target) is export {
    Seq.new(concurrent-iterator($target))
}
