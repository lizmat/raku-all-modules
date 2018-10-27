use MarkovTick;
use Time;

class MarkovTime is Time {

	method BUILD($starttime, $endtime) {

		.currenttick = new MarkovTick(newtime($endtime - $starttime)[0], 
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
			my $tick = new MarkovTick(newtime(.currenttime.seconds + $t)[0],
					newtime(.currenttime.seconds + $t)[1],
					newtime(.currenttime.seconds + $t)[2]);
			.currenttick = $tick;
			push (.ticksarray, $tick); 
		}
	} 
	
}
