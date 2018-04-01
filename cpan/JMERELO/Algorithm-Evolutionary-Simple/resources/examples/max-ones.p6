#!/usr/bin/env p6

use v6;
use Algorithm::Evolutionary::Simple;

my $length = 64;
my $population-size = 64;

my @initial-population = initialize( size => $population-size,
				     genome-length => $length );
my %fitness-of;

my $population = evaluate( population => @initial-population,
			   fitness-of => %fitness-of,
			   evaluator => &max-ones );

say "Best → ", $population.sort(*.value).reverse.[0];
while $population.sort(*.value).reverse.[0].value < $length {
    $population = generation( population => $population,
			       fitness-of => %fitness-of,
			       evaluator => &max-ones,
			       population-size => $population-size) ;

    say "Best → ", $population.sort(*.value).reverse.[0];
}
