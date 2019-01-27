use v6;
use Algorithm::Heap;

# https://en.wikipedia.org/wiki/Heap_(data_structure)

class Algorithm::Heap::Binary:ver<0.0.1>:auth<cono "q@cono.org.ua"> does Algorithm::Heap {
    has Pair @.data;

    multi method new($comparator = * <=> *) {
        self.bless(:$comparator, data => Array[Pair].new);
    }

    multi method new(:$comparator!) {
        self.bless(:$comparator, data => Array[Pair].new);
    }

    multi method new(:$comparator = * <=> *, *@input) {
        my Pair @data;
        @data.append(@input) if @input.elems;

        self.bless(:$comparator, :@data);
    }

    submethod BUILD(Comparator :$comparator, :@data) {
        $!comparator = $comparator;
        @!data := @data;

        if @!data.elems {
            for (@!data.elems div 2) ... 1 -> $index {
                self.sift-down($index);
            }
        }
    }

    # clone doesn't do @. and %. attributes automatically
    method clone {
        nextwith :data(@!data.clone);
    }

    method is-empty returns Bool {
        return @!data.elems == 0;
    }

    method size returns Int {
        return @!data.elems;
    }

    # bring it back when perl6 will have tail recursion
    #multi method sift-up(1) { };
    #multi method sift-up(Int $n) {
    #    my $cur-index = $n - 1;
    #    my $parent-index = $n div 2 - 1;
    #    my $cur = @!data[$cur-index].key;
    #    my $parent = @!data[$parent-index].key;

    #    if &!comparator($cur, $parent) < Same {
    #        @!data[$cur-index, $parent-index] = @!data[$parent-index, $cur-index];
    #        samewith($parent-index + 1);
    #    }
    #}
    method sift-up(Int $n) {
        my $it = $n;
        while ($it > 1) {
            my $cur-index = $it - 1;
            my $parent-index = $it div 2 - 1;
            my $cur = @!data[$cur-index].key;
            my $parent = @!data[$parent-index].key;

            last if $!comparator($parent, $cur) < Same;

            @!data[$cur-index, $parent-index] = @!data[$parent-index, $cur-index];
            $it = $parent-index + 1;
        }
    }

    method insert(Pair $val) {
        @!data.push($val);
        self.sift-up(@!data.elems);
    }

    # not implemented yet
    # our &push ::= &insert;

    method push(Pair $val) { self.insert($val) }

    # bring it back when perl6 will have tail recursion
    #method sift-down(Int $n) {
    #    my $left-index = $n * 2 - 1;
    #    my $right-index = $n * 2;
    #    my $target-index = $n - 1;

    #    if $left-index < @!data.elems && &!comparator(@!data[$target-index].key, @!data[$left-index].key) > Same {
    #        $target-index = $left-index;
    #    }
    #    if $right-index < @!data.elems && &!comparator(@!data[$target-index].key, @!data[$right-index].key) > Same {
    #        $target-index = $right-index;
    #    }

    #    if $target-index != $n - 1 {
    #        @!data[$n - 1, $target-index] = @!data[$target-index, $n - 1];
    #        self.sift-down($target-index + 1);
    #    }
    #}
    method sift-down(Int $n) {
        my $it = $n;

        while (True) {
            my $left-index = $it * 2 - 1;
            my $right-index = $it * 2;
            my $target-index = $it - 1;

            if $left-index < @!data.elems && $!comparator(@!data[$target-index].key, @!data[$left-index].key) > Same {
                $target-index = $left-index;
            }
            if $right-index < @!data.elems && $!comparator(@!data[$target-index].key, @!data[$right-index].key) > Same {
                $target-index = $right-index;
            }

            last if $target-index == $it - 1;

            @!data[$it - 1, $target-index] = @!data[$target-index, $it - 1];
            $it = $target-index + 1;
        }
    }

    method peek {
        return @!data.first;
    }

    # not implemented yet
    # our &find-max ::= &peek;
    # our &find-min ::= &peek;
    method find-max { self.peek }
    method find-min { self.peek }

    method pop returns Pair {
        return Nil unless @!data.elems;
        return @!data.pop if @!data.elems == 1;

        my $result = @!data.first;
        @!data[0] = @!data.pop;

        self.sift-down(1);

        return $result;
    }

    # not implemented yet
    # our &delete-max ::= &pop;
    # our &delete-min ::= &pop;
    method delete-max returns Pair { self.pop }
    method delete-min returns Pair { self.pop }

    method replace(Pair $val) returns Pair {
        my $result = @!data.first;

        @!data[0] = $val;
        self.sift-down(1);

        return $result;
    }

    method merge(Algorithm::Heap::Binary $heap) {
        my Pair @new;
        @new.append(|@!data, |$heap.data);

        return self.new(:$.comparator, |@new);
    }

    method Seq {
        Seq.new(self.iterator);
    }

    method Str {
        @!data.Str;
    }

    method iterator {
        return class :: does Iterator {
            has Algorithm::Heap::Binary $.heap is required;

            method pull-one {
                return self.heap.pop // IterationEnd;
            }
        }.new(heap => self.clone);
    }
}

=begin pod

=head1 NAME

Algorithm::Heap::Binary - Implementation of a BinaryHeap

=head1 SYNOPSIS

=begin code

    use Algorithm::Heap::Binary;

    my Algorithm::Heap::Binary $heap .= new(
        comparator => * <=> *,
        3 => 'c',
        2 => 'b',
        1 => 'a'
    );

    $heap.size.say; # 3

    # heap-sort example
    $heap.delete-min.value.say; # a
    $heap.delete-min.value.say; # b
    $heap.delete-min.value.say; # c

=end code

=head1 DESCRIPTION

Algorithm::Heap::Binary provides to you BinaryHeap data structure with basic
heap operations defined in Algorithm::Heap role:

=head2 peek

find a maximum item of a max-heap, or a minimum item of a min-heap,
respectively

=head2 push

returns the node of maximum value from a max heap [or minimum value from a min
heap] after removing it from the heap

=head2 pop

removing the root node of a max heap [or min heap]

=head2 replace

pop root and push a new key. More efficient than pop followed by push, since
only need to balance once, not twice, and appropriate for fixed-size heaps

=head2 is-empty

return true if the heap is empty, false otherwise

=head2 size

return the number of items in the heap

=head2 merge

joining two heaps to form a valid new heap containing all the elements of both,
preserving the original heaps

=head1 METHODS

=head2 Constructor

BinaryHeap contains C<Pair> objects and define order between C<Pair.key> by the
comparator. Comparator - is a C<Code> which defines how to order elements
internally. With help of the comparator you can create Min-heap or Max-heap.

=item empty constructor

=begin code

    my $heap = Algorithm::Heap::Binary.new;

=end code

Default comparator is: C<* <=> *>

=item named constructor

=begin code

    my $heap = Algorithm::Heap::Binary.new(comparator => -> $a, $b {$b cmp $a});

=end code

=item constructor with heapify

=begin code

    my @numbers = 1 .. *;
    my @letters = 'a' .. *;
    my @data = @numbers Z=> @letters;

    my $heap = Algorithm::Heap::Binary.new(comparator => * <=> *, |@data[^5]);

=end code

This will automatically heapify data for you.

=head2 clone

Clones heap object for you with all internal data.

=head2 is-empty

Returns C<Bool> result as to empty Heap or not.

=head2 size

Returns C<Int> which corresponds to amount elements in the Heap data structure.

=head2 push(Pair)

Adds new Pair to the heap and resort it.

=head2 insert(Pair)

Alias for push method.

=head2 peek

Returns C<Pair> from the top of the Heap.

=head2 find-max

Just an syntatic alias for peek method.

=head2 find-min

Just an syntatic alias for peek method.

=head2 pop

Returns C<Piar> from the top of the Heap and also removes it from the Heap.

=head2 delete-max

Just an syntatic alias for pop method.

=head2 delete-min

Just an syntatic alias for pop method.

=head2 replace(Pair)

Replace top element with another Pair. Returns replaced element as a result.

=head2 merge(Algorithm::Heap)

Construct a new Heap merging current one and passed to as an argument.

=head2 Seq

Returns C<Seq> of Heap elements. This will clone the data for you, so initial
data structure going to be untouched.

=head2 Str

Prints internal representation of the Heap (as an C<Array>).

=head2 iterator

Method wich provides iterator (C<role Iterable>). Will clone current Heap for
you.

=head2 sift-up

Internal method to make sift-up operation.

=head2 sift-down

Internal method to make sift-down operation.

=head1 AUTHOR

L<cono|mailto:q@cono.org.ua>

=head1 COPYRIGHT AND LICENSE

Copyright 2018 cono

This library is free software; you can redistribute it and/or modify it under
the Artistic License 2.0.

=head1 LINKS

=item1 L<https://en.wikipedia.org/wiki/Heap_(data_structure)>

=item1 L<https://en.wikipedia.org/wiki/Binary_heap>

=end pod

# vim: ft=perl6
