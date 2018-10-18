use Time;

class TimeChain {
	
	has $.time;
	has @.timedata;


	method BUILD(@timebasedvars, $starttime = 0.0) {

		.time = new Time($starttime, @timebasedvars.length);
		.timedata = timebasedvars;

	}

	method nth($index) {
		return .timedata[$index];
	}

}
