use v6.c;
use Test;      # a Standard module included with Rakudo 
use lib 'lib';

use Mathx::Stat::DistributionPopulation;
use Mathx::Chaos::CorrelationDimension;

my $num-tests = 2;

plan $num-tests;
 
# .... tests 
#  

my $pp = 0.1;
my $pop = Mathx::Stat::DistributionPopulation.new;

my @plist;
my @indices;

loop (my $i = $pp, my $j = 0; $i <= 1.0; $i+=0.1, $j++) {
	$pop.add($i);
	push(@plist, $i);
	push(@indices, $j);
}

my $corrdim = Mathx::Chaos::CorrelationDimension.new;

is-deeply $corrdim.dimension($pop,$pop), $corrdim.dimension($pop,$pop);
is-deeply $corrdim.morerandomdimension($pop,$pop), $corrdim.morerandomdimension($pop,$pop);

done-testing;  # optional with 'plan' 
