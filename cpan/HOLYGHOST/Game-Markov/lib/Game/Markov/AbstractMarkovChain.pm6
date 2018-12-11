use Game::Markov::TimeChain;

### The following makes a MarkovChain abstract
role MarkovP { method chance($A) { 
		### This calculates P(A|v_1,v_2,...,v_n)
			say "MarkovP, MarkovChain : Subclass responsability";
			return 0;	
	}
};

class Game::Markov::AbstractMarkovChain is Game::Markov::TimeChain does MarkovP {
	
	method BUILD(:@timebasedvars = Nil) {

		$.time = Time.new(startttime => 0, endtime => @timebasedvars.elems);
		(@.timedata = @timebasedvars) unless (not @timebasedvars) {
				@timebasedvars = ()};

	}

	method addVector($v) {
		push (@.timedata, $v);
		self.tick(1); ### add one nanotick
	}

	### abstract method, @indices are the indices of @.timedata
	method chance($A, @indices) {
		return self.chance($A);
	}

}
