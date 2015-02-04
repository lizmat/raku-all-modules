module Text::Levenshtein;

sub _min 
{
	return $^a < $^b
		?? $^a < $^c ?? $^a !! $^c
		!! $^b < $^c ?? $^b !! $^c;
}


sub distance ($s, *@t) is export
{

	my $n = $s.chars;
	my @result;

	for (@t) -> $t {
		if ($s eq $t) {
			push @result, 0;
			next;
		}
		my @d;
		my $cost=0;

		my $m = $t.chars;
		@result.push($m) and next unless $n;
		@result.push($n) and next unless $m;

		@d[0][0] = 0;
		for (1 .. $n) -> $i {
			@d[$i][0] = $i;
		}
		for (1 .. $m) -> $j {
			@d[0][$j] = $j;
		}

		for (1 .. $n) -> $i {
			my $s_i = $s.substr($i-1,1);
			for (1 .. $m) -> $j {
				@d[$i][$j] = 
				  _min(@d[$i-1][$j]+1, @d[$i][$j-1]+1,
					 @d[$i-1][$j-1]+($s_i eq substr($t,$j-1,1) ?? 0 !! 1) )
			}
		}
		push @result,@d[$n][$m];
	}
	return @result;
}


=begin pod
=head1 NAME

Text::Levenshtein - An implementation of the Levenshtein edit distance

=head1 SYNOPSIS

 use Text::Levenshtein qw(distance);

 print distance("foo","four");
 # prints "2"

 my @words=("four","foo","bar");
 my @distances=distance("foo",@words);

 print "@distances";
 # prints "2 0 3"
 

=head1 DESCRIPTION

This module implements the Levenshtein edit distance.
The Levenshtein edit distance is a measure of the degree of proximity between two strings.
This distance is the number of substitutions, deletions or insertions ("edits") 
needed to transform one string into the other one (and vice versa).
When two strings have distance 0, they are the same.
A good point to start is: <http://www.merriampark.com/ld.htm>

#See also Text::LevenshteinXS on CPAN if you do not require a perl-only implementation.  It
#is extremely faster in nearly all cases.

#See also Text::WagnerFischer on CPAN for a configurable edit distance, i.e. for
#configurable costs (weights) for the edits.


=head1 AUTHOR

Copyright 2002 Dree Mistrut <F<dree@friul.it>>
perl6 port: 2010 Steve Schulze 

This package is free software and is provided "as is" without express
or implied warranty.  You can redistribute it and/or modify it under 
the same terms as Perl itself.

=end pod

