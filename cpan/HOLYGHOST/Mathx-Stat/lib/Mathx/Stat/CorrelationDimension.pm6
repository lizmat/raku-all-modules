use Correlation;
use Dimension;

role ThisCorrelation { 
	method correlation($x,$y) { Correlation().correlation($x,$y); } 
};

class CorrelationDimension is Dimension does ThisCorrelation {

	has $.r;
	has $.rthreshold;

	method BUILD() {
		.r = 1.0;
		.rthreshold = 0.0000001;
			
	}


	### Public Methods

	method dimension($x,$y) {

		### |X - Y| < D;

		my $c = correlation($x,$y);

		return log ($c) / log (.rthreshold);
	}	

	method morerandomdimension($x,$y) {

		### |X - Y| < D; D is entropially more expensive and random

		my $c = correlation($x,$y);

		return log ($c) / log (1 / ( 1..(1 /$.rthreshold).rand);
	}	


	method dimension($x) {

		### NOTE : the limit is a sum, not the real limit :
		### D = log ($x) / log ($rr)

		$rr = .r;
		$countedlimit = 0.0;
	
		while True {
			my $countedlimit += (log $x) / (log ($rr);

			if ($rr < .rthreshold) {
				return $countedlimit;
			}
			else 
			{
				$rr /= 10;
			}
		}
	}

	method morerandomdimension($x) {

		### NOTE : the limit is a sum, not the real limit :
		### D = log ($x) / log ($rr)
		### The sum is more or less random 

		$rr = .r;
		$countedlimit = 0.0;
	
		while True {
			my $countedlimit += (log $x) / (log ($rr);

			if ($rr < .rthreshold) {
				return $countedlimit;
			}
			else 
			{
				$rr /= 1..10.rand;
			}
		}
	}

	

}
