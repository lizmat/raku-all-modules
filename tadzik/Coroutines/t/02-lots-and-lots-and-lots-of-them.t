use Coroutines;
use Test;
plan 1;

my @results;

async {
    @results.push: 1;
    yield;
    @results.push: 4;
};

async {
    @results.push: 2;
    yield;
    @results.push: 5;
};

async {
    @results.push: 3;
    yield;
    @results.push: 6;
};

schedule for 1..10;

is @results.join(','), '1,2,3,4,5,6', 'yay, correct order';
