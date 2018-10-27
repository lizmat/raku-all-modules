use Mathx::Stat;

### A list of DistributionPopulation instances
class SamplePopulation
{
	has @.distributions;

	method BUILD(@distributions = <>) { ### use the gen methods to fill
	                                    ### with random numbers
		.distributions = @distributions;
	}

	### Stratified Sampling method (a variance)

	method stratifiedsampling() {
	
		my $var = 0.0;

		for .distributions -> $x {
			$var += $x.Variance() / $x.Expectance();
		}

		return $var;

	}


	method controlvariatesmethod($index0, $index1) {
		### Monte Carlo samples with variance
		my $b = 0.01;

		return .distributions[$index0].Variance() + 2 * $b * Covariance().Covariance(.distributions[$index0], .distributions[$index1]) + $b * $b * .distributions[$index1].Variance();

	}

	method antitheticvariatesmethod($index, $function) { ### monotonic func
		my $d = new DistributionPopulation();
		my $l = new DistributionPopulation();

		for .distributions[$index].population -> $x {
			$l.add($function($x));
		}

		for .distributions[$index].population -> $x {
			$d.add($function(1-$x));
		}

		return Covariance().Covariance($l,$d);
	}

	method RaoBlackwellization($index, @indices) { 
		my $sum = 0.0;

		for @indices -> $x {
			$sum += .distributions[$index].population[$x];
		}

		return $sum / .distributions[$index].Expectance();
	}
			

}
