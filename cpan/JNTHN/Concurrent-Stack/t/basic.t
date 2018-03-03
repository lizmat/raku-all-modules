use Concurrent::Stack;
use Test;

given Concurrent::Stack.new -> $cs {
    is $cs.elems, 0, 'No elements at the start';
    nok ?$cs, 'Empty stack is falsey';
    lives-ok { $cs.push('so lock-free') }, 'Can push a value';
    is $cs.elems, 1, '1 element after pushing';
    ok ?$cs, 'Stack with a value is truthy';
    is $cs.peek, 'so lock-free', 'Can peek when 1 value';
    is $cs.elems, 1, 'Still 1 element after peeking';
    is $cs.pop, 'so lock-free', 'Can pop when 1 value';
    is $cs.elems, 0, 'No elements after popping the only value';
    nok ?$cs, 'Now-empty stack is falsey';

    my $try-peek = $cs.peek;
    isa-ok $try-peek, Failure, 'Trying to peek an empty stack fails';
    isa-ok $try-peek.exception, X::Concurrent::Stack::Empty, 'Correct exception type';
    is $try-peek.exception.operation, 'peek', 'Correct operation type in exception';

    my $try-pop = $cs.pop;
    isa-ok $try-pop, Failure, 'Trying to pop an empty stack fails';
    isa-ok $try-pop.exception, X::Concurrent::Stack::Empty, 'Correct exception type';
    is $try-pop.exception.operation, 'pop', 'Correct operation type in exception';
}

given Concurrent::Stack.new -> $cs {
    for 'a'..'f' {
        $cs.push($_);
    }
    is $cs.elems, '6', 'Elements if 6 after 6 push operations';
    is $cs.peek, 'f', 'Peeking gives stack top';
    is $cs.peek, 'f', 'Peeking again still gives stack top';
    is $cs.pop, 'f', 'Popping gives expected value';
    is $cs.pop, 'e', 'Popping again gives expected value';
    is $cs.elems, 4, 'Elements is 4 after 6 pushes and 2 pops';
}

done-testing;
