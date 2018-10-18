class Covariance { 

	method Covariance($xpop,$ypop) {
		my $ex = $xpop.Expectance();		
		my $ey = $ypop.Expectance();

		my $cov = 0.0;

		for $xpop.population, $ypop.population -> $p,$q {
			$cov += ($p - $ex)  * ($q - $ey);	
		}

		return $cov / $xpop.population.length;

	}
}
