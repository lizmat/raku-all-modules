use v6;
unit class Algorithm::MinMaxHeap;

has @.nodes;

submethod BUILD() {
}

method insert(Int:D $value) {
    @!nodes.push($value);
    self!bubble-up(@!nodes.elems - 1);
}

method find-min() {
    if (@!nodes.elems >= 1) {
	return @!nodes[0];
    }
    return Any;
}

method find-max() {
    if (@!nodes.elems == 0) {
	return Any;
    }
    elsif (@!nodes.elems == 1) {
	return @!nodes[0];
    }
    elsif (@!nodes.elems == 2) {
	return @!nodes[1];
    } else {
	return max(@!nodes[1],@!nodes[2]);
    }
}

method pop-min() {
    if (@!nodes.elems == 0) {
	return Any;
    }
    
    my $min-value = @!nodes[0];

    if (@!nodes.elems > 1) {
	@!nodes[0] = @!nodes.pop;
    } else {
	@!nodes.pop;
    }
    self!trickle-down(0);
    return $min-value;
}

method pop-max() {
    if (@!nodes.elems == 0) {
	return Any;
    }
    elsif (@!nodes.elems == 1) {
	return @!nodes.shift;
    }
    elsif (@!nodes.elems == 2) {
	return @!nodes.pop;
    }
    elsif (@!nodes[1] >= @!nodes[2]) {
	my $max-value = @!nodes[1];
	@!nodes[1] = @!nodes.pop;
	self!trickle-down(1);
	return $max-value;
    }
    elsif (@!nodes[1] < @!nodes[2]) {
	my $max-value = @!nodes[2];
	if (@!nodes.elems > 3) {
	    @!nodes[2] = @!nodes.pop;
	} else {
	    @!nodes.pop;
	}

	self!trickle-down(2);
	return $max-value;
    }
    else {
	die "ERROR: Unknown Error";
    }
}

method is-empty() returns Bool:D {
    return @!nodes.elems == 0 ?? True !! False;
}

method !bubble-up($index) {
    if (self!is-minlevel($index)) {
	if (self!has-parent($index) and (@!nodes[$index] > @!nodes[self!find-parent($index)])) {
	    self!swap(@!nodes[$index], @!nodes[self!find-parent($index)]);
	    self!bubble-up-max(self!find-parent($index));
	} else {
	    self!bubble-up-min($index);
	}
    } else {
	if (self!has-parent($index) and (@!nodes[$index] < @!nodes[self!find-parent($index)])) {
	    self!swap(@!nodes[$index], @!nodes[self!find-parent($index)]);
	    self!bubble-up-min(self!find-parent($index));
	} else {
	    self!bubble-up-max($index);
	}
    }
}

method !bubble-up-min($index) {
    if (self!has-grandparent($index)) {
	if (@!nodes[$index] < @!nodes[self!find-grandparent($index)]) {
	    self!swap(@!nodes[$index], @!nodes[self!find-grandparent($index)]);
	    self!bubble-up-min(self!find-grandparent($index));
	}
    }
}

method !bubble-up-max($index) {
    if (self!has-grandparent($index)) {
	if (@!nodes[$index] > @!nodes[self!find-grandparent($index)]) {
	    self!swap(@!nodes[$index], @!nodes[self!find-grandparent($index)]);
	    self!bubble-up-max(self!find-grandparent($index));
	}
    }
}

method !trickle-down(Int:D $index) {
    if (self!is-minlevel($index)) {
	self!trickle-down-min($index);
    } else {
	self!trickle-down-max($index);
    }
}

method !trickle-down-min(Int:D $index) {
    return if (not self!has-child($index));
    my %response = self!find-smallest($index);
    my ($smallest-index, $is-child) = %response<smallest-index>, %response<is-child>;
    if (not $is-child) {
	if (@!nodes[$smallest-index] < @!nodes[$index]) {
            self!swap(@!nodes[$smallest-index], @!nodes[$index]);
            if (@!nodes[$smallest-index] > @!nodes[self!find-parent($smallest-index)]) {
		self!swap(@!nodes[$smallest-index], @!nodes[self!find-parent($smallest-index)]);
            }
	    self!trickle-down-min($smallest-index);
	}
    } else {
        if (@!nodes[$smallest-index] < @!nodes[$index]) {
	    self!swap(@!nodes[$smallest-index], @!nodes[$index]);
        }
    }
}

method !trickle-down-max(Int:D $index) {
    return if (not self!has-child($index));
    my %response = self!find-largest($index);
    my ($largest-index, $is-child) = %response<largest-index>, %response<is-child>;
    if (not $is-child) {
	if (@!nodes[$largest-index] > @!nodes[$index]) {
            self!swap(@!nodes[$largest-index], @!nodes[$index]);
            if (@!nodes[$largest-index] < @!nodes[self!find-parent($largest-index)]) {
		self!swap(@!nodes[$largest-index], @!nodes[self!find-parent($largest-index)]);
            }
	    self!trickle-down-max($largest-index);
	}
    } else {
        if (@!nodes[$largest-index] > @!nodes[$index]) {
	    self!swap(@!nodes[$largest-index], @!nodes[$index]);
        }
    }
}

method !swap($lhs is raw, $rhs is raw) {
    ($rhs, $lhs) = $lhs, $rhs;
}

method !find-smallest(Int:D $index) {
    my ($smallest-value, $smallest-index, $is-child);
    $smallest-value = Inf;
    $smallest-index = $index;
    $is-child = False;
    
    if (self!has-left-child($index)) {
	my $left-child;
	if ($smallest-value > @!nodes[($left-child = self!find-left-child($index))]) {
	    $smallest-value = @!nodes[$left-child];
	    $smallest-index = $left-child;
	    $is-child = True;
	}

	if (self!has-left-child($left-child)) {
	    if ($smallest-value > @!nodes[self!find-left-child($left-child)]) {
		$smallest-value = @!nodes[self!find-left-child($left-child)];
		$smallest-index = self!find-left-child($left-child);
		$is-child = False;
	    }
	}
	if (self!has-right-child($left-child)) {
	    if ($smallest-value > @!nodes[self!find-right-child($left-child)]) {
		$smallest-value = @!nodes[self!find-right-child($left-child)];
		$smallest-index = self!find-right-child($left-child);
		$is-child = False;
	    }
	}
    }
    if (self!has-right-child($index)) {
	my $right-child;
	if ($smallest-value > @!nodes[($right-child = self!find-right-child($index))]) {
	    $smallest-value = @!nodes[$right-child];
	    $smallest-index = $right-child;
	    $is-child = True;
	}
	
	if (self!has-left-child($right-child)) {
	    if ($smallest-value > @!nodes[self!find-left-child($right-child)]) {
		$smallest-value = @!nodes[self!find-left-child($right-child)];
		$smallest-index = self!find-left-child($right-child);
		$is-child = False;
	    }
	}
	if (self!has-right-child($right-child)) {
	    if ($smallest-value > @!nodes[self!find-right-child($right-child)]) {
		$smallest-value = @!nodes[self!find-right-child($right-child)];
		$smallest-index = self!find-right-child($right-child);
		$is-child = False;
	    }
	}

    }
    return :$smallest-index, :$is-child;
}

method !find-largest(Int:D $index) {
    my ($largest-value, $largest-index, $is-child);
    $largest-value = -Inf;
    $largest-index = $index;
    $is-child = False;
    
    if (self!has-left-child($index)) {
	my $left-child;
	if ($largest-value < @!nodes[($left-child = self!find-left-child($index))]) {
	    $largest-value = @!nodes[$left-child];
	    $largest-index = $left-child;
	    $is-child = True;
	}

	if (self!has-left-child($left-child)) {
	    if ($largest-value < @!nodes[self!find-left-child($left-child)]) {
		$largest-value = @!nodes[self!find-left-child($left-child)];
		$largest-index = self!find-left-child($left-child);
		$is-child = False;
	    }
	}
	if (self!has-right-child($left-child)) {
	    if ($largest-value < @!nodes[self!find-right-child($left-child)]) {
		$largest-value = @!nodes[self!find-right-child($left-child)];
		$largest-index = self!find-right-child($left-child);
		$is-child = False;
	    }
	}
    }
    if (self!has-right-child($index)) {
	my $right-child;
	if ($largest-value < @!nodes[($right-child = self!find-right-child($index))]) {
	    $largest-value = @!nodes[$right-child];
	    $largest-index = $right-child;
	    $is-child = True;
	}
	
	if (self!has-left-child($right-child)) {
	    if ($largest-value < @!nodes[self!find-left-child($right-child)]) {
		$largest-value = @!nodes[self!find-left-child($right-child)];
		$largest-index = self!find-left-child($right-child);
		$is-child = False;
	    }
	}
	if (self!has-right-child($right-child)) {
	    if ($largest-value < @!nodes[self!find-right-child($right-child)]) {
		$largest-value = @!nodes[self!find-right-child($right-child)];
		$largest-index = self!find-right-child($right-child);
		$is-child = False;
	    }
	}

    }
    return :$largest-index, :$is-child;
}

method !has-grandparent(Int:D $index) returns Bool:D {
    return False if (not self!has-parent($index));
    return self!has-parent(self!find-parent($index));
}

method !find-grandparent(Int:D $index) returns Int:D {
    return self!find-parent(self!find-parent($index));
}

method !has-parent(Int:D $index) returns Bool:D {
    return $index > 0 ?? True !! False;
}

method !find-parent(Int:D $index) returns Int:D {
    return (($index - 1) / 2).Int;
}

method !has-left-child(Int:D $index) returns Bool:D {
    return ($index * 2 + 1).Int < @!nodes.elems ?? True !! False;
}

method !find-left-child(Int:D $index) returns Int:D {
    return ($index * 2 + 1).Int;
}

method !has-child(Int:D $index) returns Bool:D {
    return (self!has-left-child($index) or self!has-right-child($index));
}

method !has-right-child(Int:D $index) returns Bool:D {
    return ($index * 2 + 2).Int < @!nodes.elems ?? True !! False;
}

method !find-right-child(Int:D $index) returns Int:D {
    return ($index * 2 + 2).Int;
}

method !is-minlevel(Int:D $index) returns Bool:D {
    return (($index + 1).log(2).Int % 2 == 0 ?? True !! False);
}

=begin pod

=head1 NAME

Algorithm::MinMaxHeap - double ended priority queue

=head1 SYNOPSIS

  use Algorithm::MinMaxHeap;
  
  my $heap = Algorithm::MinMaxHeap.new();
  $heap.insert(0);
  $heap.insert(1);
  $heap.insert(2);
  $heap.insert(3);
  $heap.insert(4);
  $heap.insert(5);
  $heap.insert(6);
  $heap.insert(7);
  $heap.insert(8);

  $heap.find-max.say # 8;
  $heap.find-min.say # 0;

  my @array;
  while (not $heap.is-empty()) {
  	@array.push($heap.pop-max);
  }
  @array.say # [8, 7, 6, 5, 4, 3, 2, 1, 0]

=head1 DESCRIPTION

Algorithm::MinMaxHeap is a simple implementation of double ended priority queue.

=head2 CONSTRUCTOR

       my $heap = MinMaxHeap.new();

=head2 METHODS

=head3 insert(Int:D $value)

       $heap.insert($value);

Inserts a value to the queue.

=head3 pop-max()

       my $max-value = $heap.pop-max();

Returns a maximum value in the queue and deletes this value in the queue.

=head3 pop-min()

       my $min-value = $heap.pop-min();

Returns a minimum value in the queue and deletes this value in the queue.

=head3 find-max()

       my $max-value = $heap.find-max();

Returns a maximum value in the queue.

=head3 find-min()

       my $min-value = $heap.find-min();

Returns a minimum value in the queue.

=head3 is-empty() returns Bool:D

       while (not is-empty()) {
       	     // YOUR CODE
       }

Returns whether the queue is empty or not.

=head1 AUTHOR

okaoka <cookbook_000@yahoo.co.jp>

=head1 COPYRIGHT AND LICENSE

Copyright 2016 okaoka

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

This algorithm is from Atkinson, Michael D., et al. "Min-max heaps and generalized priority queues." Communications of the ACM 29.10 (1986): 996-1000.

=end pod
