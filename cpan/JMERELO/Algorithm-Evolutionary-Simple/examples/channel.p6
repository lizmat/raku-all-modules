#!/usr/bin/env perl6

use v6;

use Algorithm::Evolutionary::Simple;

my $length = 32;
my $supplier = Supplier.new;
my $supply   = $supplier.Supply;
my $channel-one = $supply.Channel;
my $pairs-supply = $supply.batch( elems => 2 );
my $channel-two = $pairs-supply.Channel;

my $single = start {
    react  {
        whenever $channel-one -> $item {
            say "via Channel 1:", $item;
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
