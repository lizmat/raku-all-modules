use Coroutines;
use Test;
plan 1;

my @results;
sub say($n) { @results.push: $n }

async {
    # some asynchronous thread of execution
    say 2;
    yield; # yield back to main
    say 4;
};

say 1;
schedule; # jump to async block
say 3;
schedule; # and again
say 5;
schedule; # this would do nothing, all coroutines are exhausted
say 6;

is @results.join(','), '1,2,3,4,5,6', 'yay, correct order';
