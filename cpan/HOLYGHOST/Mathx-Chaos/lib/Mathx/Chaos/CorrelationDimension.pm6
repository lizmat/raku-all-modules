use v6.c;

use Mathx::Chaos::Dimension;
use Mathx::Stat::Correlation;

role ThisCorrelationDimension { 
	method correlation($x,$y) { Mathx::Stat::Correlation.new.Correlation($x,$y); } 
};

class Mathx::Chaos::CorrelationDimension is Mathx::Chaos::Dimension does ThisCorrelationDimension {

	has $.r is rw;
	has $.rthreshold is rw;

	method BUILD() {
		$.r = 1.0;
		$.rthreshold = 0.0000001;
	}


	### Public Methods
	method correlationdimension($x,$y,$r) {

		### |X - Y| < D;

		my $c = self.correlation($x,$y);

		return log ($c + $r) / log ($r);
	}	
	

	### The following function can be used to calculate a (high) limit
	### which is a correlation dimension

	### Note that a Boltzmann function can approximate Monte Carlo samples
	### just as the dimension of the chaotic problem (dynamic system)
	

	method dimension($x,$y) {

		### |X - Y| < D;

		my $c = self.correlation($x,$y);

		return log ($c) / log ($.rthreshold);
	}	

	method morerandomdimension($x,$y) {

		### |X - Y| < D; D is entropially more expensive and random

		my $c = self.correlation($x,$y);

	return log ($c) / log (1 / ( 1..(1 /$.rthreshold).rand));
	}	


	method dimension0($x) {

		### NOTE : the limit is a sum, not the real limit :
		### D = log ($x) / log ($rr)

		my $rr = $.r;
		my $countedlimit = 0.0;
	
		while True {
			my $countedlimit += (log $x) / (log ($rr));

			if ($rr < $.rthreshold) {
				return $countedlimit;
			}
			else 
			{
				$rr /= 10;
			}
		}	
	}	

	method morerandomdimension0($x) {

		### NOTE : the limit is a sum, not the real limit :
		### D = log ($x) / log ($rr)
		### The sum is more or less random 

		my $rr = $.r;
		my $countedlimit = 0.0;
	
		while True {
			my $countedlimit += (log $x) / (log ($rr));

			if ($rr < $.rthreshold) {
				return $countedlimit;
			}
			else 
			{
				$rr /= 1..10.rand;
			}
		}
	}

}

