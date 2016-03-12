use v6;
use Algorithm::TernarySearchTree::Node;

unit class Algorithm::TernarySearchTree;

has $.root;
has Str $!record-separator = '30'.chr;

method !insert($current is raw, $key, $pos) {
    
    my $s = $key.substr($pos, 1);

    if (not $current.defined) {
	$current = Algorithm::TernarySearchTree::Node.new(split-char => $s);
    }
    if ($s lt $current.split-char) {
	$current.lokid = self!insert($current.lokid, $key, $pos);
    }
    elsif ($s eq $current.split-char) {
	if ($pos + 1 < $key.chars()) {
	    $current.eqkid = self!insert($current.eqkid, $key, $pos + 1);
	}
    } else {
	$current.hikid = self!insert($current.hikid, $key, $pos);
    }

    return $current;
}

method !contains($key, $pos is copy) {
    my $current = $!root;

    while ($current.defined) {
	my $s = $key.substr($pos, 1);
	
	if ($s lt $current.split-char) {
	    $current = $current.lokid;
	}
	elsif ($s eq $current.split-char) {
	    if (++$pos == $key.chars()) {
		return True;
	    }
	    $current = $current.eqkid;
	} else {
	    $current = $current.hikid;
	}
    }
    return False;
}

method !partial-match($current, $key, $pos, $words) {
    if ($pos == $key.chars()) {
	return $words.substr(0, $words.chars() - 1); # for terminal char
    }
    if (not $current.defined) {
	return set();
    }
    my Set $res;
    my $s = $key.substr($pos, 1);
    if ($s eq '.' || $s lt $current.split-char) {
	$res = $res (|) self!partial-match($current.lokid, $key, $pos, $words);
    }
    if ($s eq '.' || $s eq $current.split-char) {
	if ($current.split-char.defined) {
	    $res = $res (|) self!partial-match($current.eqkid, $key, $pos + 1, $words ~ $current.split-char);
	}
    }

    if ($s eq '.' || $s gt $current.split-char) {
	$res = $res (|) self!partial-match($current.hikid, $key, $pos, $words);
    }
    return $res;
}

method partial-match(Str $key) returns Set:D {
    return set() if ($key.chars() == 0);
    return self!partial-match($!root, $key ~ $!record-separator, 0, "");
}

method contains(Str $key) returns Bool:D {
    return False if ($key.chars() == 0);
    return self!contains($key ~ $!record-separator, 0);
}

method insert(Str $key) {
    return if ($key.chars() == 0);
    $!root = self!insert($!root, $key ~ $!record-separator, 0);
}

=begin pod

=head1 NAME

Algorithm::TernarySearchTree - the algorithm which blends trie and binary search tree

=head1 SYNOPSIS

  use Algorithm::TernarySearchTree;

  my $tst = Algorithm::TernarySearchTree.new();
  
  $tst.insert("Perl6 is fun");
  $tst.insert("Perl5 is fun");

  my $false-flag = $tst.contains("Kotlin is fun"); # False
  my $true-flag = $tst.contains("Perl6 is fun"); # True

  my $matched = $tst.partial-match("Perl. is fun"); # set("Perl5 is fun","Perl6 is fun")
  my $not-matched = $tst.partial-match("...lin is fun"); # set()

=head1 DESCRIPTION

Algorithm::TernarySearchTree is a implementation of the ternary search tree. Ternary search tree is the algorithm which blends trie and binary search tree.

=head2 CONSTRUCTOR

=head3 new

       my $tst = Algorithm::TernarySearchTree.new();

=head2 METHODS

=head3 insert(Str $key)

       $tst.insert($key);

Inserts the key to the tree.

=head3 contains(Str $key) returns Bool:D

       my $flag = $tst.contains($key);

Returns whether given key exists in the tree.

=head3 partial-match(Str $fuzzy-key) returns Set:D

       my Set $matched = $tst.partial-match($fuzzy-key);

Searches partially matched keys in the tree. If you want to match any character except record separator(hex: 0x1e), you can use dot symbol. For example, the query "Perl." matches "Perla", "Perl5", "Perl6", and so on.

=head2 METHODS NOT YET IMPLEMENTED

near-search, traverse, and so on.

=head1 AUTHOR

okaoka <cookbook_000@yahoo.co.jp>

=head1 COPYRIGHT AND LICENSE

Copyright 2016 okaoka

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

This algorithm is from Bentley, Jon L., and Robert Sedgewick. "Fast algorithms for sorting and searching strings." SODA. Vol. 97. 1997.

=end pod
