class Math::PascalTriangle {
	my %cache{Capture:D};
	my %LRU{Capture:D} = Bag.new;

	proto method get(Int:D() :$line! where * >= 0, Int:D() :$col! where * >= 0) {{*}}

	multi method get(:$line!, :$col! where * == 0) {1}

	multi method get(:$line!, :$col! where $line == *) {1}

	multi method get(:$line!, :$col! where $line > *) {
		%LRU{\($line, $col)}++;
		if %LRU.elems > 9999 {
			my \min = %LRU.sort(*.value)>>.key.first;
			%LRU{min}:delete;
			%cache{min}:delete;
		}
		return %cache{\($line, $col)} if %cache{\($line, $col)}:exists;
		%cache{\($line, $col)} = $.get(:line($line - 1), :$col) + $.get(:line($line - 1), :col($col - 1))
	}
}
