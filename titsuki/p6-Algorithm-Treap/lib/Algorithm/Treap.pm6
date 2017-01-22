use v6;
use Algorithm::Treap::Node;

unit role Algorithm::Treap[::KeyT];

my enum TOrder is export <DESC ASC>;

has $.root;
has TOrder $!order-by;
has Code $.gt;
has Code $.lt;
has Code $.eq;

submethod BUILD(TOrder :$!order-by) {
    if (not $!order-by.defined) {
	    $!order-by = TOrder::ASC;
    }
    if (none KeyT ~~ Str|Int) {
	    die "Error: key is Str or Int"
    }
    if (KeyT ~~ Str) {
	    $!gt = sub (Str $lhs, Str $rhs) {
	        return $lhs gt $rhs;
	    }
	    $!lt = sub (Str $lhs, Str $rhs) {
	        return $lhs lt $rhs;
	    }
	    $!eq = sub (Str $lhs, Str $rhs) {
	        return $lhs eq $rhs;
	    }
	    if ($!order-by == TOrder::DESC) {
	        $!gt = sub (Str $lhs, Str $rhs) {
		        return $lhs lt $rhs;
	        }
	        $!lt = sub (Str $lhs, Str $rhs) {
		        return $lhs gt $rhs;
	        }
	    }
    }
    elsif (KeyT ~~ Int) {
	    $!gt = sub (Int $lhs, Int $rhs) {
	        return $lhs > $rhs;
	    }
	    $!lt = sub (Int $lhs, Int $rhs) {
	        return $lhs < $rhs;
	    }
	    $!eq = sub (Int $lhs, Int $rhs) {
	        return $lhs == $rhs;
	    }
	    if ($!order-by == TOrder::DESC) {
	        $!gt = sub (Int $lhs, Int $rhs) {
		        return $lhs < $rhs;
	        }
	        $!lt = sub (Int $lhs, Int $rhs) {
		        return $lhs > $rhs;
	        }
	    }
    }
}

method !insert($current is rw, $k, $v, Num $priority) {
    if (not $current.defined) {
	    $current = Algorithm::Treap::Node.new(key => $k, value => $v, priority => $priority);
	    return $current;
    }

    if ($.eq.($k,$current.key)) {
	    die "Error: keys are duplicated";
    }
    elsif ($.lt.($k,$current.key)) {
	    $current.left-child = self!insert($current.left-child, $k, $v, $priority);

	    if ($current.left-child.priority > $current.priority) {
	        $current = self!right-rotate($current);
	    }
    }
    else {
	    $current.right-child = self!insert($current.right-child, $k, $v, $priority);

	    if ($current.right-child.priority > $current.priority) {
	        $current = self!left-rotate($current);
	    }
    }
    return $current;
}

method !delete($current is rw, $k) {
    if (not $current.defined) {
	    return $current;
    }
    
    if ($.lt.($k,$current.key)) {
	    $current.left-child = self!delete($current.left-child, $k);
	    return $current;
    }
    elsif ($.gt.($k,$current.key)) {
	    $current.right-child = self!delete($current.right-child, $k);
	    return $current;
    }

    else {
	    if (not $current.left-child.defined) {
	        return $current.right-child;
	    }
	    
	    elsif (not $current.right-child.defined) {
	        return $current.left-child;
	    }
	    
	    else {
	        if ($current.left-child.priority > $current.right-child.priority) {
		        $current = self!right-rotate($current);
		        $current.right-child = self!delete($current.right-child, $k);
		        return $current;
	        }
	        else {
		        $current = self!left-rotate($current);
		        $current.left-child = self!delete($current.left-child, $k);
		        return $current;
	        }
	    }
    }
}

method !right-rotate($y is rw) {
    my $x = $y.left-child;
    my $B = $x.right-child;
    $x.right-child = $y;
    $y.left-child = $B;
    return $x;
}

method !left-rotate($x is rw) {
    my $y = $x.right-child;
    my $B = $y.left-child;
    $y.left-child = $x;
    $x.right-child = $B;
    return $y;
}

method !find($current, $k) {
    return Any if (not $current.defined);

    if ($.lt.($k,$current.key)) {
	    return self!find($current.left-child, $k);
    }
    elsif ($.eq.($k,$current.key)) {
	    return $current;
    }
    else {
	    return self!find($current.right-child, $k);
    }
}

method !find-first-key($root) {
    return Any if (not $root.defined);
    my $current = $root;
    while ($current.left-child.defined) {
	    $current = $current.left-child;
    }
    return $current.key;
}

method !find-last-key($root) {
    return Any if (not $root.defined);
    my $current = $root;
    while ($current.right-child.defined) {
	    $current = $current.right-child;
    }
    return $current.key;
}

method find-first-key() {
    return self!find-first-key($!root);
}

method find-last-key() {
    return self!find-last-key($!root);
}

multi method insert(KeyT $k, $v) {
    if (self!find($!root, $k).defined) {
	    $!root = self!delete($!root, $k);
    }

    $!root = self!insert($!root, $k, $v, rand);
}

multi method insert(KeyT $k, $v, $priority) {
    if (self!find($!root, $k).defined) {
	    $!root = self!delete($!root, $k);
    }

    $!root = self!insert($!root, $k, $v, $priority);
}

method delete($k) {
    $!root = self!delete($!root, $k);
}

method find-value($k) {
    my $node = self!find($!root,$k);
    if ($node.defined) {
	    return $node.value;
    }
    return Any;
}

method find($k) {
    return self!find($!root,$k);
}

=begin pod

=head1 NAME

Algorithm::Treap - randomized search tree

=head1 SYNOPSIS

  use Algorithm::Treap;

  # store Int key
  my $treap = Algorithm::Treap[Int].new;
  $treap.insert(0, 0);
  $treap.insert(1, 10);
  $treap.insert(2, 20);
  $treap.insert(3, 30);
  $treap.insert(4, 40);
  my $value = $treap.find-value(3); # 30
  my $first-key = $treap.find-first-key(); # 0
  my $last-key = $treap.find-last-key(); # 4

  # delete
  $treap.delete(4);

  # store Str key
  my $treap = Algorithm::Treap[Str].new;
  $treap.insert('a', 0);
  $treap.insert('b', 10);
  $treap.insert('c', 20);
  $treap.insert('d', 30);
  $treap.insert('e', 40);
  my $value = $treap.find-value('a'); # 0
  my $first-key = $treap.find-first-key(); # 'a'
  my $last-key = $treap.find-last-key(); # 'e'

  # delete
  $treap.delete('c');


=head1 DESCRIPTION

Algorithm::Treap is a implementation of the Treap algorithm. Treap is the one of the self-balancing binary search tree. It employs a randomized strategy for maintaining balance.

=head2 CONSTRUCTOR

=head3 new

       my $treap = Algorithm::Treap[::KeyT].new(%options);

Sets either one of the type objects(Int or Str) for C<::KeyT> and some C<%options>, where C<::KeyT> is a type of insertion items to the treap.

=head4 OPTIONS

=item C<<order-by => TOrder::ASC|TOrder::DESC>>

Sets key order C<TOrder::ASC> or C<TOrder::DESC> in the treap.
Default is C<TOrder::ASC>.

=head2 METHODS

=head3 insert

	$treap.insert($key, $value);

Inserts the key-value pair to the treap.
If the treap already has the same key, it overwrites existing one.

=head3 delete

	$treap.delete($key);

Deletes the node associated with the key from the treap.

=head3 find-value

       my $value = $treap.find-value($key);

Returns the value associated with the key in the treap.
When it doesn't hit any keys, it returns type object Any.

=head3 find

       my $node = $treap.find($key);

Returns the instance of the Algorithm::Treap::Node associated with the key in the treap.
When it doesn't hit any keys, it returns type object Any.
				 
=head3 find-first-key

	my $first-key = $treap.find-first-key();

Returns the first key in the treap.

=head3 find-last-key

	my $last-key = $treap.find-last-key();

Returns the last key in the treap.

=head1 METHODS NOT YET IMPLEMENTED

join, split, finger-search, sort

=head1 AUTHOR

titsuki <titsuki@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2016 titsuki

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

The algorithm is from Seidel, Raimund, and Cecilia R. Aragon. "Randomized search trees." Algorithmica 16.4-5 (1996): 464-497.

=end pod
