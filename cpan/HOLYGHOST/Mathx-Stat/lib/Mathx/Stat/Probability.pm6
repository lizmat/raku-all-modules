
### Multi-variate probability class with a distribution of probabilities

class Probability {

	has $.population;

	method BUILD(@xpop) {
		.population = new DistributionPopulation();

		for @xpop -> $p {
			.population.add($p);
		}
	}

	### probability in the distribution
	method P($index) {
		return .population.nth($index);
	}

	### probability of both A and B, P(A and B), note the sort of A and B
	method Pand($index, $pbconda) {
		return self.P($index) * $pbconda;
	}

	### probability of A or B, P(A or B), note the sort of A and B
	method Por($index0, $index1, $pbconda) {
		return self.P($index0) + self.P($index1) - self.Pand($index0, $pbconda);
	}

	method Porp($index0, $p, $pbconda) {
		return self.P($index0) + $p - self.Pand($index0, $pbconda);
	}

	### conditional probability (pbconda == P(B|A))
	method CondP($index0, $pbconda) {
		return self.Pand($index0, $pbconda) / self.P($index0);
	}

	### conditional probability P(B|A)
	#
	# iterative calculation of conditional probability
	#
	method CalculatedCondP0($index0) {
		my $iterp = .population.nth($index0);
		my $pand = 0.0;

		### Union of i<=j Pands
		loop (my $i = 0; $i < $iterp; $i+=0.001) {
			$pand += self.Porp($index0, self.Pand($index0,$iterp), $iterp);			
		}

		return $pand;
	
	}


	### conditional probability P(B|A)
	method CalculatedCondP($index0, $n) {
		return CalculatedCondP0($index0) / self.P($n);
	}

	### Sometimes P(A|B) = P(A), so ($pbconda and self.P($index) == 1.0)
	### A and B are disjoint
	method CondPInd($index0) {
		return self.P($index0);
	}

	### Bayes conditional probability (list @pbconda == P(B|A_i))
	### B and A_i are disjoint
	method Bayes(@indices, @pbconda, $n) {

		my $bayes = @pbconda[$n] * self.P($n);
		my $sum = 0.0;

		for @indices -> $idx {
			$sum += @pbconda[$idx] * self.P($idx);
		}
		
		return $bayes / $sum;
	} 
}
