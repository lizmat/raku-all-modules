use v6;
use Algorithm::Treap::Node;

unit class Algorithm::Treap;

has $.root;
has Str $!order-by;
has Mu $!key-type is required;
has Code $.gt;
has Code $.lt;
has Code $.eq;

submethod BUILD(Str :$!order-by,Mu :$!key-type) {
    if ($!order-by.defined && $!order-by ne ('desc'|'asc')) {
	die "Error: order-by option must be desc or asc (default: asc)"
    }
    elsif (not $!order-by.defined) {
	$!order-by = 'asc';
    }
    if ((not ($!key-type === Str)) && (not ($!key-type === Int))) {
	die "Error: key-type is Str or Int"
    }
    if ($!key-type === Str) {
	$!gt = sub (Str $lhs, Str $rhs) {
	    return $lhs gt $rhs;
	}
	$!lt = sub (Str $lhs, Str $rhs) {
	    return $lhs lt $rhs;
	}
	$!eq = sub (Str $lhs, Str $rhs) {
	    return $lhs eq $rhs;
	}
	if ($!order-by eq 'desc') {
	    $!gt = sub (Str $lhs, Str $rhs) {
		return $lhs lt $rhs;
	    }
	    $!lt = sub (Str $lhs, Str $rhs) {
		return $lhs gt $rhs;
	    }
	}
    }
    elsif ($!key-type === Int) {
	$!gt = sub (Int $lhs, Int $rhs) {
	    return $lhs > $rhs;
	}
	$!lt = sub (Int $lhs, Int $rhs) {
	    return $lhs < $rhs;
	}
	$!eq = sub (Int $lhs, Int $rhs) {
	    return $lhs == $rhs;
	}
	if ($!order-by eq 'desc') {
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

multi method insert($k, $v) {
    if (not ($k.WHAT === $!key-type)) {
	die "Error: key type violation";
    }
    if (self!find($!root, $k).defined) {
	$!root = self!delete($!root, $k);
    }

    $!root = self!insert($!root, $k, $v, rand);
}

multi method insert($k, $v, $priority) {
    if (not ($k.WHAT === $!key-type)) {
	die "Error: key type violation";
    }
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
  my $treap = Algorithm::Treap.new(key-type => Int);
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
  my $treap = Algorithm::Treap.new(key-type => Str);
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

       my $treap = Algorithm::Treap.new(%options);

=head4 OPTIONS

=item C<<key-type => Int|Str>>

Sets either one of the type objects(Int or Str) for keys which you use to insert items to the treap.

=item C<<order-by => 'asc'|'desc'>>

Sets key order 'asc' or 'desc' in the treap.
Default is 'asc'.

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

okaoka <cookbook_000@yahoo.co.jp>

=head1 COPYRIGHT AND LICENSE

Copyright 2016 okaoka

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

The algorithm is from Seidel, Raimund, and Cecilia R. Aragon. "Randomized search trees." Algorithmica 16.4-5 (1996): 464-497.

=end pod
