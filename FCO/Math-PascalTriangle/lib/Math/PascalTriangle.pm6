class Math::PascalTriangle {
	my $triangle = [[1]];

	method !generate-line(Int \index-nu where * > 0) {
		my \prev = index-nu - 1;

		self!generate-line(prev) if not $triangle[prev]:exists;

		$triangle[index-nu; 0, index-nu] = 1, 1;
		my \line	= $triangle[index-nu];
		my \prev-line	= $triangle[prev];

		for 1 ..^ index-nu -> $index {
			line[$index] = [+] prev-line[$index - 1, $index]
		}
	}

	proto method get(Int :$line!, Int :$col!) {
		{*}
	}

	multi method get(Int :$line!, Int :$col! where * == 0) {1}

	multi method get(Int :$line!, Int :$col! where $line == *) {1}

	multi method get(Int :$line!, Int :$col! where $line > *) {
		self!generate-line($line) if $line >= $.cached-lines;
		$triangle[$line; $col]
	}

	method cached-lines {
		$triangle.elems
	}
}
