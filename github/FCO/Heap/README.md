[![Build Status](https://travis-ci.org/FCO/Heap.svg?branch=master)](https://travis-ci.org/FCO/Heap)

# Heap

A simple perl6 module implementing the heap data structure.

```perl6
my Heap $heap .= new: 9, 7, 5, 3, 1;
$heap.push: 8;
say $heap.pop;		# 1
say $heap.pop;		# 3
say $heap.pop;		# 5

say $heap.all		# (7, 8, 9)

```

```perl6
my Heap[-*] $heap .= new: <9 7 5 3 1>;
$heap.push: 8;
say $heap.pop;		# 9
say $heap.pop;		# 8
say $heap.pop;		# 7

```

```perl6
my Heap[{$^b <=> $^a}] $heap .= new: <9 7 5 3 1>;
$heap.push: 8;
say $heap.pop;		# 9
say $heap.pop;		# 8
say $heap.pop;		# 7

```

```perl6
my Heap[*<order>] $heap .= new:
	{:something<ble>, :order<2>},
	{:something<bla>, :order<1>},
	{:something<bli>, :order<3>},
	{:something<blu>, :order<5>},
;
$heap.push: {:something<blo>, :order<4>},
say $heap.pop;		# {:something<bla>, :order<1>}
say $heap.pop;		# {:something<ble>, :order<2>}
say $heap.pop;		# {:something<bli>, :order<3>}

```
