use v6.c;

class Mathx::Stat::Population
{
	has @.population;

	method BUILD() {
	}

	method add($x) {
		push(.population, $x);
	}

	method nth($index) {
		return .population[$index];
	}

}

