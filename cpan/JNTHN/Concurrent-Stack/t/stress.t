use Concurrent::Stack;
use Test;

my $stack = Concurrent::Stack.new;
my @threads = do for 1..3 -> $id {
    Thread.start: {
        $stack.push($_) for ^50000;
    }
}
@threads>>.join;

my atomicint $total = 0;
@threads = do for 1..3 -> $id {
    Thread.start: {
        $total ⚛+= $stack.pop() for ^50000;
    }
}
@threads>>.join;

is $total, 3 * [+](^50000), 'Pushed/popped correct values';

done-testing;
