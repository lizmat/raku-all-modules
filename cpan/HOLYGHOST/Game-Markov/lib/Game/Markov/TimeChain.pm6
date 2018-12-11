use Game::Markov::Time;

class Game::Markov::TimeChain {
	
	has $.time is rw;
	has @.timedata is rw;


	method BUILD(@timebasedvars, $starttime = 0.0) {

		$.time = Time.new(starttime => $starttime, endtime => @timebasedvars.elems);
		@.timedata = @timebasedvars;

	}

	method nth($index) {
		return @.timedata[$index];
	}

}
