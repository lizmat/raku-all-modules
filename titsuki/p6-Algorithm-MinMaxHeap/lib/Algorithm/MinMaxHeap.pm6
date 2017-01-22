use v6;
unit role Algorithm::MinMaxHeap[::Type];

use Algorithm::MinMaxHeap::Comparable;
use Algorithm::MinMaxHeap::CmpOperator;

has Type @.nodes;

submethod BUILD() {}

method insert($value) {
    @!nodes.push($value);
    self!bubble-up(@!nodes.elems - 1);
}

method find-min() {
    if @!nodes.elems >= 1 {
        return @!nodes[0];
    }
    return Type;
}

method find-max() {
    if @!nodes.elems == 0 {
        return Type;
    }
    elsif @!nodes.elems == 1 {
        return @!nodes[0];
    }
    elsif @!nodes.elems == 2 {
        return @!nodes[1];
    } else {
        if @!nodes[1] minmaxheap-cmp @!nodes[2] == Order::More {
            return @!nodes[1];
        }
        else {
            return @!nodes[2];
        }
    }
}

method pop-min() {
    if @!nodes.elems == 0 {
        return Type;
    }
    
    my $min-value = @!nodes[0];

    if @!nodes.elems > 1 {
        @!nodes[0] = @!nodes.pop;
    } else {
        @!nodes.pop;
    }
    self!trickle-down(0);
    return $min-value;
}

method pop-max() {
    if @!nodes.elems == 0 {
        return Type;
    }
    elsif @!nodes.elems == 1 {
        return @!nodes.shift;
    }
    elsif @!nodes.elems == 2 {
        return @!nodes.pop;
    }
    elsif @!nodes[1] minmaxheap-cmp @!nodes[2] == Order::Same|Order::More {
        my $max-value = @!nodes[1];
        @!nodes[1] = @!nodes.pop;
        self!trickle-down(1);
        return $max-value;
    }
    elsif @!nodes[1] minmaxheap-cmp @!nodes[2] == Order::Less {
        my $max-value = @!nodes[2];
        if @!nodes.elems > 3 {
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

method is-empty returns Bool:D {
    return @!nodes.elems == 0 ?? True !! False;
}

method clear {
    @!nodes = ();
}

method clone {
    nextwith(:nodes(@.nodes.clone))
}

method !bubble-up($index) {
    if self!is-minlevel($index) {
        if self!has-parent($index) and (@!nodes[$index] minmaxheap-cmp @!nodes[self!find-parent($index)] == Order::More) {
            self!swap(@!nodes[$index], @!nodes[self!find-parent($index)]);
            self!bubble-up-max(self!find-parent($index));
        } else {
            self!bubble-up-min($index);
        }
    } else {
        if self!has-parent($index) and (@!nodes[$index] minmaxheap-cmp @!nodes[self!find-parent($index)] == Order::Less) {
            self!swap(@!nodes[$index], @!nodes[self!find-parent($index)]);
            self!bubble-up-min(self!find-parent($index));
        } else {
            self!bubble-up-max($index);
        }
    }
}

method !bubble-up-min($index) {
    if self!has-grandparent($index) {
        if @!nodes[$index] minmaxheap-cmp @!nodes[self!find-grandparent($index)] == Order::Less {
            self!swap(@!nodes[$index], @!nodes[self!find-grandparent($index)]);
            self!bubble-up-min(self!find-grandparent($index));
        }
    }
}

method !bubble-up-max($index) {
    if self!has-grandparent($index) {
        if @!nodes[$index] minmaxheap-cmp @!nodes[self!find-grandparent($index)] == Order::More {
            self!swap(@!nodes[$index], @!nodes[self!find-grandparent($index)]);
            self!bubble-up-max(self!find-grandparent($index));
        }
    }
}

method !trickle-down(Int:D $index) {
    if self!is-minlevel($index) {
        self!trickle-down-min($index);
    } else {
        self!trickle-down-max($index);
    }
}

method !trickle-down-min(Int:D $index) {
    return if not self!has-child($index);
    my %response = self!find-smallest($index);
    my ($smallest-index, $is-child) = %response<smallest-index>, %response<is-child>;
    if not $is-child {
        if @!nodes[$smallest-index] minmaxheap-cmp @!nodes[$index] == Order::Less {
            self!swap(@!nodes[$smallest-index], @!nodes[$index]);
            if @!nodes[$smallest-index] minmaxheap-cmp @!nodes[self!find-parent($smallest-index)] == Order::More {
                self!swap(@!nodes[$smallest-index], @!nodes[self!find-parent($smallest-index)]);
            }
            self!trickle-down-min($smallest-index);
        }
    } else {
        if @!nodes[$smallest-index] minmaxheap-cmp @!nodes[$index] == Order::Less {
            self!swap(@!nodes[$smallest-index], @!nodes[$index]);
        }
    }
}

method !trickle-down-max(Int:D $index) {
    return if not self!has-child($index);
    my %response = self!find-largest($index);
    my ($largest-index, $is-child) = %response<largest-index>, %response<is-child>;
    if not $is-child {
        if @!nodes[$largest-index] minmaxheap-cmp @!nodes[$index] == Order::More {
            self!swap(@!nodes[$largest-index], @!nodes[$index]);
            if @!nodes[$largest-index] minmaxheap-cmp @!nodes[self!find-parent($largest-index)] == Order::Less {
                self!swap(@!nodes[$largest-index], @!nodes[self!find-parent($largest-index)]);
            }
            self!trickle-down-max($largest-index);
        }
    } else {
        if @!nodes[$largest-index] minmaxheap-cmp @!nodes[$index] == Order::More {
            self!swap(@!nodes[$largest-index], @!nodes[$index]);
        }
    }
}

method !swap($lhs is raw, $rhs is raw) {
    ($rhs, $lhs) = $lhs, $rhs;
}

method !find-smallest(Int:D $index) {
    my ($smallest-value, $smallest-index, $is-child);
    $smallest-value = Type;
    $smallest-index = $index;
    $is-child = False;
    
    if self!has-left-child($index) {
        my $left-child = self!find-left-child($index);
        if not $smallest-value.defined or $smallest-value minmaxheap-cmp @!nodes[$left-child] == Order::More {
            $smallest-value = @!nodes[$left-child];
            $smallest-index = $left-child;
            $is-child = True;
        }

        if self!has-left-child($left-child) {
            if not $smallest-value.defined or $smallest-value minmaxheap-cmp @!nodes[self!find-left-child($left-child)] == Order::More {
                $smallest-value = @!nodes[self!find-left-child($left-child)];
                $smallest-index = self!find-left-child($left-child);
                $is-child = False;
            }
        }
        if self!has-right-child($left-child) {
            if not $smallest-value.defined or $smallest-value minmaxheap-cmp @!nodes[self!find-right-child($left-child)] == Order::More {
                $smallest-value = @!nodes[self!find-right-child($left-child)];
                $smallest-index = self!find-right-child($left-child);
                $is-child = False;
            }
        }
    }
    if self!has-right-child($index) {
        my $right-child = self!find-right-child($index);
        if not $smallest-value.defined or $smallest-value minmaxheap-cmp @!nodes[$right-child] == Order::More {
            $smallest-value = @!nodes[$right-child];
            $smallest-index = $right-child;
            $is-child = True;
        }
        
        if self!has-left-child($right-child) {
            if not $smallest-value.defined or $smallest-value minmaxheap-cmp @!nodes[self!find-left-child($right-child)] == Order::More {
                $smallest-value = @!nodes[self!find-left-child($right-child)];
                $smallest-index = self!find-left-child($right-child);
                $is-child = False;
            }
        }
        if self!has-right-child($right-child) {
            if not $smallest-value.defined or $smallest-value minmaxheap-cmp @!nodes[self!find-right-child($right-child)] == Order::More {
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
    $largest-value = Type;
    $largest-index = $index;
    $is-child = False;
    
    if self!has-left-child($index) {
        my $left-child = self!find-left-child($index);
        if not $largest-value.defined or $largest-value minmaxheap-cmp @!nodes[$left-child] == Order::Less {
            $largest-value = @!nodes[$left-child];
            $largest-index = $left-child;
            $is-child = True;
        }

        if self!has-left-child($left-child) {
            if not $largest-value.defined or $largest-value minmaxheap-cmp @!nodes[self!find-left-child($left-child)] == Order::Less {
                $largest-value = @!nodes[self!find-left-child($left-child)];
                $largest-index = self!find-left-child($left-child);
                $is-child = False;
            }
        }
        if self!has-right-child($left-child) {
            if not $largest-value.defined or $largest-value minmaxheap-cmp @!nodes[self!find-right-child($left-child)] == Order::Less {
                $largest-value = @!nodes[self!find-right-child($left-child)];
                $largest-index = self!find-right-child($left-child);
                $is-child = False;
            }
        }
    }
    if self!has-right-child($index) {
        my $right-child = self!find-right-child($index);
        if not $largest-value.defined or $largest-value minmaxheap-cmp @!nodes[$right-child] == Order::Less {
            $largest-value = @!nodes[$right-child];
            $largest-index = $right-child;
            $is-child = True;
        }
        
        if self!has-left-child($right-child) {
            if not $largest-value.defined or $largest-value minmaxheap-cmp @!nodes[self!find-left-child($right-child)] == Order::Less {
                $largest-value = @!nodes[self!find-left-child($right-child)];
                $largest-index = self!find-left-child($right-child);
                $is-child = False;
            }
        }
        if self!has-right-child($right-child) {
            if not $largest-value.defined or $largest-value minmaxheap-cmp @!nodes[self!find-right-child($right-child)] == Order::Less {
                $largest-value = @!nodes[self!find-right-child($right-child)];
                $largest-index = self!find-right-child($right-child);
                $is-child = False;
            }
        }

    }
    return :$largest-index, :$is-child;
}

method !has-grandparent(Int:D $index) returns Bool:D {
    return False if not self!has-parent($index);
    return self!has-parent(self!find-parent($index));
}

method !find-grandparent(Int:D $index) returns Int:D {
    return self!find-parent(self!find-parent($index));
}

method !has-parent(Int:D $index) returns Bool:D {
    return $index > 0 ?? True !! False;
}

method !find-parent(Int:D $index) returns Int:D {
    return ($index - 1) div 2;
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
    return (($index + 1).log(2).Int %% 2 ?? True !! False);
}

=begin pod

=head1 NAME

Algorithm::MinMaxHeap - A Perl 6 implementation of double ended priority queue

=head1 SYNOPSIS

=head2 EXAMPLE1

  use Algorithm::MinMaxHeap;

  my $heap = Algorithm::MinMaxHeap[Int].new;
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
  @array.push($heap.pop-max) until $heap.is-empty;
  @array.say # [8, 7, 6, 5, 4, 3, 2, 1, 0]

=head2 EXAMPLE2

  use Algorithm::MinMaxHeap;
  use Algorithm::MinMaxHeap::Comparable;

  # sets compare-to method using Algorithm::MinMaxHeap::Comparable role
  my class State {
     also does Algorithm::MinMaxHeap::Comparable[State];
     has Int $.value;
     has $.payload;
     submethod BUILD(:$!value) { }
     method compare-to(State $s) {
            if $!value == $s.value {
               return Order::Same;
            }
            if $!value > $s.value {
               return Order::More;
            }
            if $!value < $s.value {
               return Order::Less;
            }
     }
  }

  # specify Algorithm::MinMaxHeap::Comparable role as an item type
  my $class-heap = Algorithm::MinMaxHeap[Algorithm::MinMaxHeap::Comparable].new;
  $class-heap.insert(State.new(value => 0));
  $class-heap.insert(State.new(value => 1));
  $class-heap.insert(State.new(value => 2));
  $class-heap.insert(State.new(value => 3));
  $class-heap.insert(State.new(value => 4));
  $class-heap.insert(State.new(value => 5));
  $class-heap.insert(State.new(value => 6));
  $class-heap.insert(State.new(value => 7));
  $class-heap.insert(State.new(value => 8));
  
  $class-heap.find-max.value.say # 8;
  $class-heap.find-min.value.say # 0;

  my @array;
  until $class-heap.is-empty {
  	my $state = $class-heap.pop-max;
  	@array.push($state.value);
  }
  @array.say # [8, 7, 6, 5, 4, 3, 2, 1, 0]

=head1 DESCRIPTION

Algorithm::MinMaxHeap is a simple implementation of double ended priority queue.

=head2 CONSTRUCTOR

Defined as:

        role Algorithm::MinMaxHeap[::Type] {}

Usage:

       my $heap = Algorithm::MinMaxHeap[Int].new;
       my $heap = Algorithm::MinMaxHeap[Rat].new;
       my $heap = Algorithm::MinMaxHeap[Algorithm::MinMaxHeap::Comparable].new;

Sets C<::Type> parameter, where C<::Type> is a type of nodes in the queue.

Use C<subset> for creating complex type constraints:

     my subset MyCool of Cool where Int|Num|Rat;
     my $heap = Algorithm::MinMaxHeap[MyCool].new;

=head2 METHODS

=head3 insert($item)

       $heap.insert($item);

Inserts an item to the queue.

=head3 pop-max()

       my $max-value-item = $heap.pop-max();

Returns a maximum value item in the queue and deletes this item in the queue.

=head3 pop-min()

       my $min-value-item = $heap.pop-min();

Returns a minimum value item in the queue and deletes this item in the queue.

=head3 find-max()

       my $max-value-item = $heap.find-max();

Returns a maximum value item in the queue.

=head3 find-min()

       my $min-value-item = $heap.find-min();

Returns a minimum value item in the queue.

=head3 is-empty() returns Bool:D

       while (not $heap.is-empty()) {
       	     // YOUR CODE
       }

Returns whether the queue is empty or not.

=head3 clear()

       $heap.clear();

Deletes all items in the queue.

=head1 CAUTION

Don't insert both numerical items and stringified items into the same queue.

It will cause mixing of lexicographical order and numerical order.

=head1 AUTHOR

titsuki <titsuki@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2016 titsuki

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

This algorithm is from Atkinson, Michael D., et al. "Min-max heaps and generalized priority queues." Communications of the ACM 29.10 (1986): 996-1000.

=end pod
