use Test;
use Concurrent::Iterator;

plan 16;

{
    my class TestEndIter does Iterator {
        has $.calls = 0;

        method pull-one() {
            $!calls++;
            state $current = 2;
            $current == 0
                ?? IterationEnd
                !! $current--
        }
    }

    my $test-iter = TestEndIter.new;
    my $ri = Concurrent::Iterator.new(Seq.new($test-iter));
    is $ri.pull-one, 2, "First pull-one gets correct value";
    is $test-iter.calls, 1, "One call on underlying iterator so far";
    is $ri.pull-one, 1, "Second pull-one gets correct value";
    is $test-iter.calls, 2, "Two calls on underlying iterator so far";
    ok $ri.pull-one =:= IterationEnd, "Third pull-one gets IterationEnd";
    is $test-iter.calls, 3, "Three calls on underlying iterator so far";
    ok $ri.pull-one =:= IterationEnd, "Further pull-one gets IterationEnd";
    is $test-iter.calls, 3, "However, no more calls on underlying iterator";
}

{
    my class TestDeathIter does Iterator {
        has $.calls = 0;

        method pull-one() {
            $!calls++;
            state $current = 2;
            $current == 0
                ?? die "hard"
                !! $current--
        }
    }

    my $test-iter = TestDeathIter.new;
    my $ri = Concurrent::Iterator.new(Seq.new($test-iter));
    is $ri.pull-one, 2, "First pull-one gets correct value";
    is $test-iter.calls, 1, "One call on underlying iterator so far";
    is $ri.pull-one, 1, "Second pull-one gets correct value";
    is $test-iter.calls, 2, "Two calls on underlying iterator so far";
    dies-ok { $ri.pull-one }, "Third pull-one died";
    is $test-iter.calls, 3, "Three calls on underlying iterator so far";
    dies-ok { $ri.pull-one }, "Further pull-one also dies";
    is $test-iter.calls, 3, "However, no more calls on underlying iterator";
}
