class Math::PascalTriangle {
	my %cache{Capture:D};
	my %LRU{Capture:D} = Bag.new;

	proto method get(UInt:D() :$line!, UInt:D() :$col!) {{*}}

	multi method get(:$line!, :$col! where * == 0) {1}

	multi method get(:$line!, :$col! where $line == *) {1}

	multi method get(:$line!, :$col! where $line > *) {
		%LRU{\($line<>, $col<>)}++;
		if %LRU.elems > 9999 {
			my \min = %LRU.sort(*.value)>>.key.first;
			%LRU{min}:delete;
			%cache{min}:delete;
		}
		return $_ with %cache{\($line<>, $col<>)};
		%cache{\($line<>, $col<>)} = $.get(:line($line - 1), :$col) + $.get(:line($line - 1), :col($col - 1))
	}
}
