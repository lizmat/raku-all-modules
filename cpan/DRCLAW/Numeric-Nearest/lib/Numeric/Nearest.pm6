#!/usr/bin/env perl6
unit module Nearest;
#|Finds the nearest element in the array and returns a pair 
#|index => value
#|
sub nearestPair ($key, $list,:$start) is export {
	my int $lower=0;
	my int $upper=$list.elems-1; #say $upper;
	my int $mid= $start.defined??$start!!  ($upper+$lower) div 2;
	my $result;
	if $key < $list[0] {
		#out of range. return the start of the list
		$result = 0=>$list[0];
	}
	elsif $key > $list[*-1] {
		#out of range. return the end of the list
		$result= $list.elems-1=>$list[*-1];
	}
	else {
		#start the search proper
		my int $previousMid=-1;
		loop (my int $i=0; $i < $list.elems; $i++ ) {

			if $previousMid == $mid {
				#fidn the closes neighbour
				my $a=($key - $list[$mid]).abs;
				my $limit=$mid+1;
				if $limit >= $list.elems {
					$limit= $list.elems-1;
				}
				my $b=($key - $list[$limit]).abs;

				if $a < $b {

					$result= $mid=>$list[$mid];
				}
				else {
					$result= $limit=>$list[$limit];
				}
				last;
			}
			given $list {
				when ($key > .[$mid] ) {
					#in upper half
					$lower=$mid;

				}
				when $key < .[$mid] {
					$upper=$mid;
				}
				when $key == .[$mid] {
					#exact match
					$result=$mid=>$list[$mid];
					last;
				}

			}
			$previousMid=$mid;
			$mid=($lower+$upper) div 2;
		}
	}
	$result;
}

#|Returns a sequence of pairs
#|
sub nearestPairs ($keys,$list) is export {	
	$keys.map({
		state $start =0;
		my $t=nearestPair( $_,$list,:$start);
		$start=$t.key;
		$t;
	})
}
