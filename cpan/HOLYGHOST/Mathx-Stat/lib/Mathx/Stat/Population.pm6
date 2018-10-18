class Population
{
	has @.population;

	method BUILD() {
		.population = <>;
	}

	method add($x) {
		push(.population, $x);
	}

	method nth($index) {
		return .population[$index];
	}

}

