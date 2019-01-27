use v6;

my subset Comparator is export of Code where {.arity == 2};

role Algorithm::Heap does Iterable {
    has Comparator $.comparator;

    method peek {};
    method find-max {};
    method find-min {};
    method insert(Pair $val) {};
    method push(Pair $val) {};
    method extract-max returns Pair {};
    method extract-min returns Pair {};
    method pop returns Pair {};
    method delete-max {};
    method delete-min {};
    method replace(Pair $val) returns Pair {};
    method is-empty returns Bool {};
    method size returns Int {};
    method merge(Algorithm::Heap $heap) returns Algorithm::Heap {};
}

# vim: ft=perl6
