class RandomStratifiers
{
	has $.cmax, $lambda;
	has $.phifunc;

	has $b;

	method BUILD(:$c) {
		.cmax = $c;
		.lambda = ($cmax + sqrt($cmax * $cmax + 4)) / 2
		.phifunc = phifunc;	

		.b = exp((.lambda * .lambda - 2 * .lambda * cmax) /2) / 
			sqrt(2 * PI) * .lambda * (1 - .phifunc(c));

		
	}

	method reinit($c) {
		.cmax = $c;
		.lambda = ($cmax + sqrt($cmax * $cmax + 4)) / 2;

		.b = exp((.lambda * .lambda - 2 * .lambda * cmax) /2) / 
			sqrt(2 * PI) * .lambda * (1 - .phifunc(c));
	}

	method phifunc ($x) {

	}

	method exponentialdistribution($x) { 
		return (.b * .lambda * exp(- .lambda * $x));
	}	

	method phi_x_plus_c($x) { ### phi (x + c)
		return self.exponentialdistribution($x) * (1 - .phifunc(.cmax));
	}	

	method chance($x, $c) {
		self.reinit($c);
		return self.phi_x_plus_c($x);
	}

	method gen() { ### generate a truncated Gaussian random probability
		       ### which is exponential and uniform distributed
		       ### This can be put in a population/distribution array
		       ### which sets a fractal landscape to use at init
		       ### and runtime of the AI in your game (random behaviour)
		return self.chance(0..1000000.rand, 0);
	}

	method phifunc ($x) {
		return $x;
	}

}
