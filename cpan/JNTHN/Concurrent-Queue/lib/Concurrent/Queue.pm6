class X::Concurrent::Queue::Empty is Exception {
    method message() {
        "Cannot dequeue from an empty queue"
    }
}

class Concurrent::Queue {
    # Each value in the queue is held in a node, which points to the next
    # value to dequeue, if any.
    my class Node {
        has $.value;
        # Must not rely on auto-initialization of attributes when using CAS,
        # as it will be racey.
        has Node $.next is rw = Node;
    }
    has Node $.head;
    has Node $.tail;
    has atomicint $!elems;

    submethod BUILD(--> Nil) {
        # Head and tail initially point to a dummy node.
        $!head = $!tail = Node.new;
    }

    method enqueue($value --> Nil) {
        my $node = Node.new: :$value;
        my $tail;
        loop {
            $tail = $!tail;
            my $next = $tail.next;
            if $tail === $!tail {
                if $next.DEFINITE {
                    # Something else inserted to the queue, but $!tail was not
                    # yet updated. Help by updating it (and don't check the
                    # outcome, since if we fail another thread did this work
                    # in our place).
                    cas($!tail, $tail, $next);
                }
                else {
                    last if cas($tail.next, $next, $node) === $next;
                }
            }
        }
        # Try to update $!tail to point to the new node. If we fail, it's
        # because we didn't get to do this soon enough, and another thread did
        # it in order that it could make progress. Thus a failure to swap here
        # is fine.
        cas($!tail, $tail, $node);
        $!elems⚛++;
    }

    method dequeue() {
        loop {
            my $head = $!head;
            my $tail = $!tail;
            my $next = $head.next;
            if $head === $!head {
                if $head === $tail {
                    # Head and tail point to the same place. Two cases:
                    if $next.DEFINITE {
                        # The head node has a next. This means there is an
                        # enqueue in montion that did not manage to update the
                        # $!tail yet. Help it on its way; failure to do so
                        # is fine, it just means another thread did it.
                        cas($!tail, $tail, $next);
                    }
                    else {
                        # Head and tail point to a dummy node and there's no
                        # ongoing insertion. That means the queue is empty.
                        fail X::Concurrent::Queue::Empty.new;
                    }
                }
                else {
                    if cas($!head, $head, $next) === $head {
                        # Successfully dequeued. The head node is always a
                        # dummy. The value is in the next node. That node
                        # becomes the new dummy.
                        $!elems⚛--;
                        return $next.value;
                    }
                }
            }
        }
    }

    multi method elems(Concurrent::Queue:D: -->  Int) {
        $!elems
    }

    multi method Bool(Concurrent::Queue:D: --> Bool) {
        $!elems != 0
    }
}
