use v6.c;

use Mathx::Stat::Population;

class Mathx::Stat::DistributionPopulation is Mathx::Stat::Population
{
	method BUILD() {
		
	}

	method Expectance() {

		my $e = 0.0;

		for .population -> $p {
			$e += $p;
		}

		return $e / .population.elems;
	}

	method Variance () {
		my $e = .Expectance();
		my $var = 0.0;

		for .population -> $p {
			$var += ($p - $e) * ($p - $e);
		}

		return $var / (.population.elems - 1);
	}


}

