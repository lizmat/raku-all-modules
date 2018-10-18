use Population;

class DistributionPopulation is Population
{
	method BUILD() {
		
	}

	method Expectance() {

		my $e = 0.0;

		for .population -> $p {
			$e += $p;
		}

		return $e / .population.length;
	}

	method Variance () {
		my $e = .Expectance();
		my $var = 0.0;

		for .population -> $p {
			$var += ($p - $e) * ($p - $e);
		}

		return $var / (.population.length - 1);
	}


}

