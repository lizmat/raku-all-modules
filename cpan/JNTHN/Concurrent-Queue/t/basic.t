use Concurrent::Queue;
use Test;

given Concurrent::Queue.new -> $cq {
    is $cq.elems, 0, 'Elements count starts out as 0';
    nok $cq, 'Empty queue is falsey';

    my $fail = $cq.dequeue;
    isa-ok $fail, Failure, 'Dequeue of an empty queue fails';
    isa-ok $fail.exception, X::Concurrent::Queue::Empty,
        'Correct exception type in Failure';

    lives-ok { $cq.enqueue(42) }, 'Can enqueue a value';
    lives-ok { $cq.enqueue('beef') }, 'Can enqueue another value';
    is $cq.elems, 2, 'Correct element count after two enqueues';
    is $cq.dequeue, 42, 'Dequeue gives the first enqueued value';
    is $cq.elems, 1, 'Correct element count after two enqueues and one dequeue';
    ok $cq, 'Non-empty queue is truthy';
    lives-ok { $cq.enqueue('kebab') }, 'Can enqueue another value after dequeueing';
    is $cq.dequeue, 'beef', 'Second dequeue is second enqueued value';
    is $cq.dequeue, 'kebab', 'Third dequeue is third enqueued value';
    is $cq.elems, 0, 'Elements count should be 0 after all is dequeued';
    nok $cq, 'Empty-again queue is falsey';

    $fail = $cq.dequeue;
    isa-ok $fail, Failure, 'Dequeue of now-empty queue again fails';

    lives-ok { $cq.enqueue('schnitzel') }, 'Can enqueue to the now-empty queue';
    is $cq.dequeue, 'schnitzel', 'And can dequeue the value';

    $fail = $cq.dequeue;
    isa-ok $fail, Failure, 'Again, dequeue of now-empty-again queue fails';
}

done-testing;
