use Concurrent::Queue;
use Test;

# This test has a bunch of workers doing concurrent enqueue/dequeue operations.
# Each worker first enqueues a set of pairs (id, counter) where counter is per
# worker. It then starts dequeueing in a loop. It keeps state per worker of
# the last counter it store per ID, and dies if we ever see out of order
# counters per ID. At the end we add up the values we saw to make sure that
# none got lost.

my constant THREADS = 4;

my $cq = Concurrent::Queue.new;
my @worker-results = await do for 1..THREADS -> $id {
    start {
        for ^50000 -> $counter {
            $cq.enqueue(($id, $counter));
        }

        my %seen = flat 1..THREADS Z -1 xx THREADS;
        my %sum = flat 1..THREADS Z 0 xx THREADS;
        while $cq.dequeue -> @tuple {
            my $deq-id = @tuple[0];
            my $deq-counter = @tuple[1];
            die "Out of sequence" if %seen{$deq-id} >= $deq-counter;
            %seen{$deq-id} = $deq-counter;
            %sum{$deq-id} += $deq-counter;
        }

        %sum
    }
}

my %summed = [>>+<<] @worker-results;
my $expected = [+] ^50000;
for 1..THREADS {
    is %summed{$_}, $expected, "Correct sum of dequeued values ($_)";
}

done-testing;
