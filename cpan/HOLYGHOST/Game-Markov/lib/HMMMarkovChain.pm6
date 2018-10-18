use MarkovChain;

### Vector based Chain (HMM == Hidden Markov Model)

class HMMMarkovChain is MarkovChain {
	
	method addVector($v) {
		self.add($v);
		self.time.tick(1); ### add one virtual second tick 
				   ### so that the chain is second-indexable
	}

	### This calculates P(A|v_1,v_2,...,v_n) with @indices in .timedata
	method chance($A, @indices) {
		return self.chance($A);
	}

	method chance($A) {
		return undef;
	}
	
}
