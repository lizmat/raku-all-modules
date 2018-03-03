class X::Concurrent::Stack::Empty is Exception {
    has Str $.operation is required;
    method message() {
        "Cannot $!operation from an empty concurrent stack"
    }
}

class Concurrent::Stack {
    my class Node {
        has $.value;
        has Node $.next;
    }

    has Node $!head;
    has atomicint $!elems;

    method push(Concurrent::Stack:D: $value) {
        cas $!head, -> $next {
            Node.new: :$value, :$next
        }
        $!elems⚛++;
        return $value;
    }

    method pop(Concurrent::Stack:D:) {
        my $taken;
        cas $!head, -> $current {
            fail X::Concurrent::Stack::Empty.new(:operation<pop>) without $current;
            $taken = $current.value;
            $current.next
        }
        $!elems⚛--;
        return $taken;
    }

    method peek(Concurrent::Stack:D:) {
        my $current = ⚛$!head;
        fail X::Concurrent::Stack::Empty.new(:operation<peek>) without $current;
        return $current.value;
    }

    multi method elems(Concurrent::Stack:D: -->  Int) {
        $!elems
    }

    multi method Bool(Concurrent::Stack:D: --> Bool) {
        $!elems != 0
    }
}
