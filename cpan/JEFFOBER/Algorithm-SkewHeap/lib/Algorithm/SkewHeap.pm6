=begin pod

=head1 NAME

Algorithm::SkewHeap - a mergable min heap

=head1 VERSION

0.0.1

=head1 SYNOPSIS

  use Algorithm::SkewHeap;

  my $heap = Algorithm::SkewHeap.new;

  for (1 .. 1000).pick(1000) -> $n {
    $heap.put($n);
  }

  until $heap.is-empty {
    my $n = $heap.take;
  }

  $heap.merge($other-heap);


=head1 DESCRIPTION

A skew heap is a type of heap based on a binary tree in which all operations
are based on merging subtrees, making it possible to quickly combine multiple
heaps, while still retaining speed and efficiency. Ammortized performance is
O(log n) or better (see L<https://en.wikipedia.org/wiki/Skew_heap>).

=head1 SORTING

Items in the heap are returned with the lowest first. Comparisons are done with
the greater than operator, which may be overloaded as needed for types intended
to be used in the heap.

=end pod

my class Node {
  has Node $.left  is rw;
  has Node $.right is rw;
  has $.value is rw;

  method explain(Int $depth = 0) {
    print '  ' for 1..$depth;
    say "-Value: $!value";

    if $!left.DEFINITE {
      print '  ' for 1..$depth;
      say '-Left';
      $!left.explain($depth + 1);
    }

    if $!right.DEFINITE {
      print '  ' for 1..$depth;
      say '-Right';
      $!right.explain($depth + 1);
    }
  }
}


multi sub merge(Node:U $a, Node:U $b) { return    }
multi sub merge(Node:D $a, Node:U $b) { return $a }
multi sub merge(Node:U $a, Node:D $b) { return $b }

multi sub merge(Node:D $a, Node:D $b) {
  return $a unless $b.DEFINITE;
  return $b unless $a.DEFINITE;
  return $a.value > $b.value
    ?? merge($b, $a)
    !! Node.new(
      left  => merge($b, $a.right),
      right => $a.left,
      value => $a.value,
    );
}


#| SkewHeap class
class Algorithm::SkewHeap:ver<0.0.1> {
  has Node $!root;
  has Int  $!nodes = 0;

  #| Returns the number of items in the heap
  method size(--> Int) {
    return $!nodes;
  }

  #| Returns true when the heap is empty
  method is-empty(--> Bool) {
    return $!nodes == 0;
  }

  #| Returns the top item in the heap without removing it.
  method top(--> Any) {
    return unless $!nodes;
    return unless $!root.DEFINITE;
    $!root.value;
  }

  #| Removes and returns the top item in the heap.
  method take(--> Any) {
    my $value = self.top // return;
    $!root = merge($!root.left, $!root.right);
    --$!nodes;
    $value;
  }

  #| Adds a new item to the heap. Returns the new size of the heap.
  method put(Any $value --> Int) {
    $!root = merge($!root, Node.new(value => $value));
    ++$!nodes;
  }

  #| Destructively merges with another heap. The other heap should be
  #| considered unusable afterward. Returns the new size of the heap.
  method merge(Algorithm::SkewHeap $other --> Int) {
    my $count = $other.nodes;
    my $root = $other.root;

    # Zero out the other heap to ensure no shared structure
    $other.nodes = 0;
    $other.root = Nil;

    $!root = merge($!root, $root);
    $!nodes += $count;
    $!nodes;
  }

  #| Prints the structure of the heap for debugging purposes.
  method explain(--> Nil) {
    say "SkewHeap: size=$!nodes";
    $!root.explain(1);
    return;
  }
}

