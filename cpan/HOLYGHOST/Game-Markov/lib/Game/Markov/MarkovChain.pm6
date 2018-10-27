use TimeChain;

### Non-vector based Chain

class MarkovChain is TimeChain {
	
	method BUILD(@timebasedvars = undef) {

		.time = new Time(0, @timebasedvars.length);
		(.timedata = @timebasedvars) unless (not @timebasedvars) {
				@timebasedvars = <>}; ### markov chain vectors

	}

	method add($v) {
		push (.timedata, $v);
	}

}
