#| Impleementation of Heap data structure
role Heap[$heap_cmp = * cmp *] {
	#| The comparator function
	has &.cmp = do given $heap_cmp {
		when Callable	{$_					}
		when Whatever	{ -> $val {$val}	}
		default			{ -> $ {$heap_cmp}	}
	};
	#| The array with the heap data
	has Any @.data;

	method !cmp($a, $b) {
		do if &!cmp.signature.params.elems == 1 {
			&!cmp($a) cmp &!cmp($b)
		} else {
			&!cmp($a, $b)
		}
	}

	#| Receives a array and transforms that array in a Heap (O(n))
	method new(+@arr is copy) {
		my $obj = self.bless: :data(@arr);
		$obj.rebuild;
		$obj
	}

	method rebuild {
		for reverse 0 .. self!get-parent(+@!data) -> UInt \i {
			self!down(i);
		}
	}

	method !get-parent(UInt \node)    {  (node - 1) div 2 }
	method !get-left(UInt \node)      {  (node * 2) + 1 }
	method !get-right(UInt \node)     {  (node * 2) + 2 }

	method !swap(UInt \i, UInt \j) {
		@!data[i, j] = @!data[j, i]
	}

	method !up(UInt \i where 0 < * < @!data) {
		my \parent = self!get-parent:	i;
		if self!cmp(@!data[i], @!data[parent]) < 0 {
			self!swap:	i, parent;
			self!up:	parent if parent
		}
	}

	method !down(UInt \i where * < @!data) {
		my \left	= self!get-left:	i;
		my \right	= self!get-right:	i;

		return if left >= @!data;

		if right >= @!data or self!cmp(@!data[left], @!data[right]) < 0 {
			if self!cmp(@!data[left], @!data[i]) < 0 {
				self!swap: i, left;
				self!down: left;
			}
		} elsif right >= @!data {
			return
		} elsif self!cmp(@!data[right], @!data[i]) < 0 {
			self!swap: i, right;
			self!down: right
		}
	}

	method gist {
		::?CLASS.^name ~ ".new: {@!data.gist}";
	}

	method Numeric {
		+@!data
	}

	method Array {
		@!data
	}

	method Bag {
		@!data.Bag
	}

	method Set {
		@!data.Set
	}

	method Bool {
		?@!data
	}

	multi method ACCEPTS(@other) {
		self.Array.sort(&!cmp) == @other
	}

	multi method ACCEPTS(::?CLASS $other) {
		self.Array.sort(&!cmp) == $other.Array.sort(&!cmp)
	}

	multi method ACCEPTS($other where *.can("Array")) {
		self.Array.sort(&!cmp) == $other.Array.sort(&!cmp)
	}

	#| Add a ney value on the Heap
	method push($new) {
		@!data.push: $new;
		self!up: @!data.elems - 1 if @!data.elems > 1
	}

	#| Removes and returns the first element of the heap
	method pop {
		return Any unless @!data;
		my \ret = @!data.shift;
		if self {
			@!data.unshift: @!data.pop;
			self!down: 0;
		}
		ret
	}

	#| Returns the first element of the heap
	method peek {
		return Any unless @!data;
		@!data.head
	}

	#| Pops the Heap until its empty
	method all {
		gather take $.pop while self
	}

}

