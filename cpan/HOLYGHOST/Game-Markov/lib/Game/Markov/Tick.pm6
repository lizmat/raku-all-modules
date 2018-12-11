class Game::Markov::Tick {

	### NOTE : seconds are tick based not real time seconds e.g. the time
	###        is virtual but uses nanoseconds as a measure of virtual time
	### 	   This class holds a virtual nanosecond time duration

	has $.seconds;
	has $.milliseconds;
	has $.nanoseconds;

	has $.time; ### total nanosecond time
	has $.tick; ### tick number or id, sorted or not

	method BUILD(:$s, :$ms, :$ns, :$t = Nil) {

		$.seconds = $s;
		$.milliseconds = $ms;
		$.nanoseconds = $ns;

		$.tick = $t;

	}

	method time() {

		$.time = $.seconds + $.milliseconds / 1000 + $.nanoseconds / 1000000;

		return $.time;
	}

	method tick() {
		return $.tick;
	}
}
