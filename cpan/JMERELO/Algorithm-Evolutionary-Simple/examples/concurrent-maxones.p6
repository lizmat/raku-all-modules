#!/usr/bin/env perl6

use v6;

use Algorithm::Evolutionary::Simple;

my $length = 64;
my $population-size = 64;
my $generations = 16;
my $supplier = Supplier.new;
my $supply   = $supplier.Supply;
my $channel-one = $supply.Channel;
my $pairs-supply = $supply.batch( elems => 2 );
my $channel-two = $pairs-supply.Channel;

my $single = start {
    react  {
        whenever $channel-one -> $population is copy {
            say "via Channel 1:";
	    my $count = 0;
	    my %fitness-of;
	    while $count++ < $generations && $population.sort(*.value).reverse.[0].value < $length {
		LAST { $supplier.emit( $population ) if $count < $generations };
		$population = generation( population => $population,
					  fitness-of => %fitness-of,
					  evaluator => &max-ones,
					  population-size => $population-size) ;
		
		say "Best → ", $population.sort(*.value).reverse.[0];
	    }
	    
        }
    }
}

my $pairs = start {
    react  {
        whenever $channel-two -> @pair {
	    say "In Channel 2: ", crossover( @pair[0], @pair[1] );
        }
    }
}

await (^3).map: -> $r {
    start {
	sleep $r/1000.0;
	my @initial-population = initialize( size => $population-size,
					     genome-length => $length );
	my %fitness-of;	
	my $population = evaluate( population => @initial-population,
				   fitness-of => %fitness-of,
				   evaluator => &max-ones );
        $supplier.emit( $population );
    }
}

$supplier.done;
await $single;
await $pairs;
