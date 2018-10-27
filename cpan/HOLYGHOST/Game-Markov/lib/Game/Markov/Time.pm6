use Tick;

role ThisTime { method ticksover($time, $t) { return $time + $t; } 
		method newtime($time) { ### return tuple of time in s,ms,ns
				return (<($time
				- $time / 1000
				- $time / 1000000),
				($time - ($time / 1000000) * 1000) % 1000
				($time * 1000000) % 1000>);
		}
}; 

class Time does ThisTime {

	has $.currenttime;  ### current time, last Tick start time + delta(t)
	has $.currenttick;  ### end - start time in a Tick instance 
			    ### before new Tick (this holds a duration)

	has @.ticksarray; ### previous and current Tick array

	method BUILD($starttime, $endtime) {

		.currenttick = new Tick(newtime($endtime - $starttime)[0], 
					newtime($endtime - $starttime)[1], 
					newtime($endtime - $starttime)[2]); 
				

		.currenttime = $starttime;

	}

	method tick($t) { ### $t in ticks ~ seconds (decimal)
		if ($t < .currenttick.time()) { 
			### $t is not beyond last tick (end)time
			.currenttime += $t;

			return ticksover(.currenttime, $t);

		} else {
			### push a new Tick as last Tick has expired
			.currenttime += $t;
			my $tick = new Tick(newtime(.currenttime.seconds + $t)[0],
					newtime(.currenttime.seconds + $t)[1],
					newtime(.currenttime.seconds + $t)[2]);
			.currenttick = $tick;
			push (.ticksarray, $tick); 
		}
	} 
	
}
