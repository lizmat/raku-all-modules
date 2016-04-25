use v6;
unit class Algorithm::BinaryIndexedTree;

has @!tree;
has Int $!size;

multi submethod BUILD(Int:D :$!size) {
    for 0..$!size { @!tree.push(0); }
}

multi submethod BUILD() {
    $!size = 1000;
    for 0..$!size { @!tree.push(0); }
}

method sum(Int $last-index) {
    if ($last-index > $!size) {
	die "Error: index must be smaller than table size";
    }
    elsif ($last-index < 0) {
	die "Error: index must be larger or equal to 0";
    }

    my $sum = @!tree[0];
    my Int $current-index = $last-index;
    while ($current-index > 0) {
	$sum += @!tree[$current-index];
	$current-index = $current-index +& ($current-index - 1);
    }
    return $sum;
}

method add(Int $index, $value) {
    if ($index > $!size) {
	die "Error: index must be smaller than table size";
    }
    elsif ($index < 0) {
	die "Error: index must be larger or equal to 0";
    }
    elsif ($index == 0) {
	@!tree[0] += $value;
	return;
    }
    
    my Int $current-index = $index;
    while ($current-index <= $!size) {
	@!tree[$current-index] = @!tree[$current-index] + $value;
	$current-index += $current-index +& -$current-index;
    }
}

method get(Int $index) {
    if ($index > $!size) {
	die "Error: index must be smaller than table size";
    }
    elsif ($index < 0) {
	die "Error: index must be larger or equal to 0";
    }

    my Int $current-index = $index;
    my $value = @!tree[$index];
    if ($current-index > 0) {
	my $parent = $current-index +& ($current-index - 1);
	$current-index -= 1;
	while ($parent != $current-index) {
	    $value -= @!tree[$current-index];
	    $current-index = $current-index +& ($current-index - 1);
	}
    }
    return $value;
}

=begin pod

=head1 NAME

Algorithm::BinaryIndexedTree - data structure for cumulative frequency tables

=head1 SYNOPSIS

  use Algorithm::BinaryIndexedTree;
  
  my $BIT = Algorithm::BinaryIndexedTree.new();
  $BIT.add(5,10);
  $BIT.get(0).say; # 0
  $BIT.get(5).say; # 10
  $BIT.sum(4).say; # 0
  $BIT.sum(5).say; # 10

  $BIT.add(0,10);
  $BIT.sum(5).say; # 20
  
=head1 DESCRIPTION

Algorithm::BinaryIndexedTree is the data structure for maintainig the cumulative frequencies.

=head2 CONSTRUCTOR

=head3 new

       my $BIT = Algorithm::BinaryIndexedTree.new(%options);

=head4 OPTIONS

=item C<<size => $size>>

Sets table size. Default is 1000.

=head2 METHODS

=head3 add

      $BIT.add($index, $value);

Adds given value to the index C<<$index>>.

=head3 sum

       my $sum = $BIT.sum($index);

Returns sum of the values of items from index 0 to index C<<$index>> inclusive.

=head3 get

      my $value = $BIT.get($index);

Returns the value at index C<<$index>>.

=head1 AUTHOR

titsuki <titsuki@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2016 titsuki

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

The algorithm is from Fenwick, Peter M. "A new data structure for cumulative frequency tables." Software: Practice and Experience 24.3 (1994): 327-336.

=end pod
