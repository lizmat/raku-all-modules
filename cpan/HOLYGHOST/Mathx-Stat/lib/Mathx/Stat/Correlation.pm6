use v6.c;

role ThisCovariance { method cov($xpop,$ypop) {
	return Covariance().Covariance($xpop,$ypop);
}
}
		

class Mathx::Stat::Correlation does ThisCovariance {
	method BUILD() {
			
	}

	method correlation($xpop,$ypop) { ### These are distribution args
	
		my $varx = $xpop.Variance(), $vary = $ypop.Variance();
		my $cov = self.cov($xpop, $ypop);

		return $cov / (sqrt($varx) * sqrt($vary)); 

	}
}
