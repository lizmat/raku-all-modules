use Test;
use Concurrent::Iterator;

plan 3;

my $ir = Concurrent::Iterator.new(^100000);
my @results = await do for ^2 {
    start {
        my @collected;
        until (my \pulled = $ir.pull-one) =:= IterationEnd {
            @collected.push(pulled);
        }
        @collected
    }
}
ok all(@results),
    "Both threads got some results";
is @results[0] + @results[1], 100000,
    "Got correct number of results between threads";
is [+](@results[0]) + [+](@results[1]), [+](^100000),
    "Correct values were taken by the threads together";
