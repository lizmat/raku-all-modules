use Mathx::Stat;

### A list of DistributionPopulation instances
class Game::Markov::SamplePopulation
{
	has @.distributions is rw;

	method BUILD(@distributions) { ### use the gen methods to fill
	                                    ### with random numbers
		@.distributions = @distributions;
	}

	### Stratified Sampling method (a variance)

	method stratifiedsampling() {
	
		my $var = 0.0;

		for @.distributions -> $x {
			$var += $x.Variance() / $x.Expectance();
		}

		return $var;

	}


	method controlvariatesmethod($index0, $index1) {
		### Monte Carlo samples with variance
		my $b = 0.01;

		return @.distributions[$index0].Variance() + 2 * $b * Covariance().Covariance(@.distributions[$index0], @.distributions[$index1]) + $b * $b * @.distributions[$index1].Variance();

	}

	method antitheticvariatesmethod($index, $function) { ### monotonic func
		my $d = Mathx::Stat::DistributionPopulation.new();
		my $l = Mathx::Stat::DistributionPopulation.new();

		for @.distributions[$index].population -> $x {
			$l.add($function($x));
		}

		for @.distributions[$index].population -> $x {
			$d.add($function(1-$x));
		}

		return Covariance().Covariance($l,$d);
	}

	method RaoBlackwellization($index, @indices) { 
		my $I = 0.0;

		for @indices -> $x {
			$I += @.distributions[$index].population[$x];
		}

		 $I /= @.distributions[$index].Expectance();

		my @ps = <>;	
		for @indices -> $x {
			push(@ps, @.distributions[$index].population[$x]);	
		}

		my $varI = 0.0;
		my $Ipop = Mathx::Stat::DistributionPopulation.new(@ps);
		$varI = $Ipop.Variance() / $Ipop.Expectance();	

		my $p = new Probability(@ps);
		my $sp = new SamplePopulation();
		@ps = <>;
		my $idx = 0;
		for $p.population.population -> $x {
			my $idx2 = 0;
			@ps = <>;
			for $p.population.population -> $x2 {
				push(@ps, $p.CalculatedCondP($idx, $p.CalculatedCondP($idx2,$idx)));
				$idx2++;
			}
			$idx++;
			$sp.population.add(Mathx::Stat::DistributionPopulation.new(@ps));
		}


		my $varI2 = 0.0;
		my $I2 = 0.0;
		my $estimates = Mathx::Stat::DistributionPopulation.new;
		for $sp.population -> $x {
			$I2 += $x.population.Expectance();
			$estimates.add($x.population.Expectance());
		}
		$I2 /= $idx;

		$varI2 = $estimates.Variance();

		return ($varI, $var2I);

	}
			

}
