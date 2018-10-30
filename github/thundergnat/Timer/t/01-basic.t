use Test;
use Timer;

plan 5;

my ($answer, $time) = timer { my $i = sum((1..1000) »R/» 1) for ^10; $i }

is-approx( $answer, 7.485470860550344, 'Returns a reasonable value');

ok( 0 < $time < 20, 'Returns a reasonable time');

lives-ok( { ($answer, $time) = timer( sub{ } ) }, 'Doesn\'t choke on an empty sub');

lives-ok( { ($answer, $time) = timer( {; } ) }, 'Doesn\'t choke on an empty block');

dies-ok( {timer( sum(5..500) )}, 'Dies when not given a callable');

done-testing;
