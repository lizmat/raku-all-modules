use v6.c;
use Test;      # a Standard module included with Rakudo 
use lib 'lib';

use Game::Markov::AbstractMarkovChain;
use Game::Markov::SamplePopulation;

my $num-tests = 4;

plan $num-tests;
 
# .... tests
#  

my @distribs;

my $distrib0 = Mathx::Stat::DistributionPopulation.new;
my $distrib1 = Mathx::Stat::DistributionPopulation.new;

loop (my $i = 0; $i < 100; $i++) {
	$distrib0.add(1/$i);
}

loop (my $i = 0; $i < 10000; $i+=3) {
	$distrib1.add(1/$i);
}

push(@distribs, $distrib0);
push(@distribs, $distrib1);

my $sampledistribs =  Game::Markov::SamplePopulation.new(distributions => @distribs);

is-deeply $sampledistribs.stratifiedsampling, $sampledistribs.stratifiedsampling;
is-deeply $sampledistribs.controlvariatesmethod(index0 => 0), $sampledistribs.controlvariatesmethod(index1 => 0);

is-deeply Game::Markov::AbstractMarkovChain.new, Game::Markov::AbstractMarkovChain.new;

my @l;

loop (my $i = 0; $i < 4; $i++) {
	push(@l,$i);
}

is-deeply $sampledistribs.RaoBlackwellization(index0 => 0, indeices => @l), $sampledistribs.RaoBlackwellization(0, @l);



done-testing;  # optional with 'plan' 
