#!/usr/bin/env perl6

use v6;

use Algorithm::Evolutionary::Simple;

sub selecto-recombinative-EA( |parameters (
				    UInt :$length = 64,
				    UInt :$population-size = 256,
				    UInt :$diversify-size = 8,
				    UInt :$max-evaluations = 10000,
				    UInt :$tournament-size = 4
				)) {

    # Channel definition
    my Channel $raw .= new;
    my Channel $evaluated .= new;
    my Channel $channel-three = $evaluated.Supply.batch( elems => $tournament-size).Channel;
    my Channel $shuffler = $raw.Supply.batch( elems => $diversify-size).Channel;
    my Channel $output .= new;

    # Creates initial population
    $raw.send( random-chromosome($length).list ) for ^$population-size;
    
    my $count = 0;
    my $end;
    my $shuffle = start react whenever $shuffler -> @group {
	my @shuffled = @group.pick(*);
	$raw.send( $_ ) for @shuffled;
    }
    
    my $evaluation = start react whenever $raw -> $one {
	my $with-fitness = $one => max-ones($one);
	$output.send( $with-fitness );
	$evaluated.send( $with-fitness);
	say $count++, " → $with-fitness";
	if $with-fitness.value == $length {
	    $raw.close;
	    $end = "Solution found";
	}
	if $count >= $max-evaluations {
	    $raw.close;
	    $end = "Solution not found";
	}
    }
    
    my $selection = start react whenever $channel-three -> @tournament {
	my @ranked = @tournament.sort( { .values } ).reverse;
	$evaluated.send( $_ ) for @ranked[0..1];
	$raw.send( $_.list ) for crossover(@ranked[0].key,@ranked[1].key);
    }
    
    await $evaluation;
    
    loop {
	if my $item = $output.poll {
	    $item.say;
	} else {
	    $output.close;
	}
	if $output.closed  { last };
    }
    
    say "Parameters ==";
    say "Evaluations => $count";
    for parameters.kv -> $key, $value {
	say "$key → $value";
    };
    say "=============";
    return $end;
}


sub MAIN ( UInt :$repetitions = 30,
           UInt :$length = 64,
	   UInt :$population-size = 512,
	   UInt :$diversify-size = 8,
	   UInt :$max-evaluations = 10000,
	   UInt :$tournament-size = 4 ) {

    my $found;
    for ^$repetitions {
	my $result = selecto-recombinative-EA( length => $length,
					       population-size => $population-size,
					       diversify-size => $diversify-size,
					       max-evaluations => $max-evaluations,
					       tournament-size => $tournament-size );
	$found++ if $result eq "Solution found";
    }
    say "Result ", $found/$repetitions;

}
