unit module Mathx::Stat;

class Population
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

