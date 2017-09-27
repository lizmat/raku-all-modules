use lib 'lib';

use Scientist;
use Test;

plan 1;

class MyScientist is Scientist {
    has $.test_value is rw;
    method publish {
        $.test_value = 101;
    }
}

my $experiment = MyScientist.new(
    experiment => 'Tree',
    try        => sub {99},
    use        => sub {88},
);

$experiment.run;

is $experiment.test_value, 101, 'Publish set the value we expected';
