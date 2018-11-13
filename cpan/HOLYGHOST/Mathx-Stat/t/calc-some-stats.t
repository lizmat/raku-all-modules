use v6.c;
use Test;      # a Standard module included with Rakudo 
use lib 'lib';

use Mathx::Stat::DistributionPopulation;

my $num-tests = 2;

plan $num-tests;
 
# .... tests 
#  

my $p = 0.1;
my $pop = Mathx::Stat::DistributionPopulation.new;

loop (my $i = $p; $p <= 1.0; $p+=0.1) {
	$pop.add($p);
}

####say "--->" ~ $pop.Expectance ~ "--->" ~ $pop.Variance;

ok $pop.Expectance, 0.1;

### FIXME
ok $pop.Variance, $pop.Variance;

done-testing;  # optional with 'plan' 

