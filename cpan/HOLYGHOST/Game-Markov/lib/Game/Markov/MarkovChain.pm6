use TimeChain;

### Non-vector based Chain

class MarkovChain is TimeChain {
	
	method BUILD(:@timebasedvars) {

		$.time = Time.new(startttime => 0, endtime => @timebasedvars.elems);
		(@.timedata = @timebasedvars) unless (not @timebasedvars) {
				@timebasedvars; }; ### markov chain vectors

	}

	method add($v) {
		push (@.timedata, $v);
	}

}
