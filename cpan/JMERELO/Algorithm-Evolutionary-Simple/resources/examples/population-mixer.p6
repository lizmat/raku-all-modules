#!/usr/bin/env perl6

use v6;

use Algorithm::Evolutionary::Simple;

sub mixer-EA( |parameters (
		    UInt :$length = 64,
		    UInt :$initial-populations = 3,
		    UInt :$population-size = 256,
		    UInt :$generations = 8,
		    UInt :$threads = 1
		)
	    ) {
    
    my Channel $channel-one .= new;
    my Channel $to-mix .= new;
    my Channel $mixer = $to-mix.Supply.batch( elems => 2).Channel;
    
    my $evaluations = 0;

    # Initialize three populations for the mixer
    for ^$initial-populations {
	my @initial-population = initialize( size => $population-size,
					     genome-length => $length );
	my %fitness-of;	
	my $population = evaluate( population => @initial-population,
				   fitness-of => %fitness-of,
				   evaluator => &max-ones );
	$evaluations += $population.elems;
	$channel-one.send( $population );
    }
    
    my $single = ( start react whenever $channel-one -> $crew {
	my $population = $crew.Bag;
	my $count = 0;
	my %fitness-of = $population.Hash;
	while $count++ < $generations && best-fitness($population) < $length {
	    LAST {
		if best-fitness($population) >= $length {
		    say "Solution found" => $evaluations;
		    $channel-one.close;
		} else {
		    say "Emitting after $count generations in thread ", $*THREAD.id, " Best fitness ",best-fitness($population)  ;
		    $to-mix.send( $population );
		}
	    };
	    $population = generation( population => $population,
				      fitness-of => %fitness-of,
				      evaluator => &max-ones,
				      population-size => $population-size);
	    
	    $evaluations += $population.elems;
	}
    
    } ) for ^$threads;
    
    my $pairs = start react whenever $mixer -> @pair {
	$to-mix.send( @pair.pick ); # To avoid getting it hanged up
	$channel-one.send(mix( @pair[0], @pair[1], $population-size ));
	say "Mixing in ", $*THREAD.id;
    };
    
    
    await $single;
    say "Parameters ==";
    say "Evaluations => $evaluations";
    for parameters.kv -> $key, $value {
	say "$key → $value";
    };
    say "=============";
    return $evaluations;
}

sub MAIN ( UInt :$repetitions = 30,
	   UInt :$initial-populations = 3,
           UInt :$length = 64,
	   UInt :$population-size = 256,
	   UInt :$generations=8,
	   UInt :$threads = 1 ) {

    my @results;
    for ^$repetitions {
	my $result = mixer-EA( length => $length,
			       initial-populations => $initial-populations,
			       population-size => $population-size,
			       generations => $generations,
			       threads => $threads );
	push @results, $result;
    }

    say @results;
}
