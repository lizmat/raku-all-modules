use v6.c;

unit class Algorithm::Evolutionary::Simple:ver<0.0.4>;

sub random-chromosome( UInt $length ) is export {
    return Bool.pick() xx $length;
}

sub initialize( UInt :$size,
		UInt :$genome-length ) is export {
    my @initial-population;
    for 1..$size -> $p {
	@initial-population.push: random-chromosome( $genome-length );
    }
    return @initial-population;
}

sub max-ones( @chromosome ) is export {
    return @chromosome.sum;
}

sub royal-road( @chromosome ) is export {
    return @chromosome.rotor(4).grep( so (*.all == True|False) ).elems;
}

sub evaluate( :@population,
	      :%fitness-of,
	      :$evaluator --> Bag ) is export {
    my BagHash $pop-bag;
    for @population -> $p {
	if  ! %fitness-of{$p}.defined {
	    %fitness-of{$p} = $evaluator( $p );
	}
	$pop-bag{$p} = %fitness-of{$p};
    }
    return $pop-bag.Bag;
}

sub get-pool-roulette-wheel( Bag $population,
			     UInt $need = $population.elems ) is export {
    return $population.pick: $need;
}

sub mutation ( @chromosome is copy ) is export {
    my $pick = (^@chromosome.elems).pick;
    @chromosome[ $pick ] = !@chromosome[ $pick ];
    return @chromosome;
}

sub crossover ( @chromosome1 is copy, @chromosome2 is copy ) is export {
    my $length = @chromosome1.elems;
    my $xover1 = (^($length-2)).pick;
    my $xover2 = ($xover1^..^$length).pick;
    my @x-chromosome = @chromosome2;
    my @þone = $xover1..$xover2;
    @chromosome2[@þone] = @chromosome1[@þone];
    @chromosome1[@þone] = @x-chromosome[@þone];
    return [@chromosome1,@chromosome2];
}

sub produce-offspring( @pool,
		       $size = @pool.elems ) is export {
    my @new-population;
    for 1..($size/2) {
	my @χx = @pool.pick: 2;
	@new-population.push: crossover(@χx[0], @χx[1]).Slip;
    }
    return @new-population.map( { mutation( $^þ ) } );
    
}

sub best-fitness(Bag $population ) is export {
    return $population.sort(*.value).reverse.[0].value;
}

sub generation(Bag :$population,
	       :%fitness-of,
	       :$evaluator,
	       :$population-size = $population.elems --> Bag ) is export {

#    say "Elems in generation ", $population.elems;
    my $best = $population.sort(*.value).reverse.[0..1].Bag;
    my @pool = get-pool-roulette-wheel( $population, $population-size-2);
    my @new-population= produce-offspring( @pool, $population-size );
    return  Bag(evaluate( population => @new-population,
			  fitness-of => %fitness-of,
			  evaluator => $evaluator ) ∪ $best );
    
    
}

sub mix( $population1, $population2, $size --> Bag) is export {
    my $new-population = $population1 ∪ $population2;
    return $new-population.sort(*.value).reverse.[0..($size-1)].Bag;
}

=begin pod

=head1 NAME

Algorithm::Evolutionary::Simple - A simple evolutionary algorithm

=head1 SYNOPSIS

  use Algorithm::Evolutionary::Simple;

=head1 DESCRIPTION

Algorithm::Evolutionary::Simple is a module for writing simple and
quasi-canonical evolutionary algorithms in Perl 6. It uses binary
representation, integer fitness (which is needed for the kind of data
structure we are using) and a single fitness function.

It is intended mainly for demo purposes. In the future,
more versions will be available.			

It uses a fitness cache for storing and not reevaluating,
so take care of memory bloat.
   
=head1 METHODS

=head2 initialize( UInt :$size,
		   UInt :$genome-length ) is export

Creates the initial population

=head2 random-chromosome( $length )

Generates a random chromosome

=head2 max-ones( @chromosome )

Returns the number of trues or ones in the chromosome

=head2 royal-road( @chromosome )

That's a bumpy road, returns 1 for each block of 4 which has the same true or false value.

=head2 evaluate( :@population,
		 :%fitness-of,
		 :$evaluator --> Bag ) is export

Evaluates the chromosomes, storing values in the fitness cache. 

=head2 get-pool-roulette-wheel( Bag $population,
				UInt $need = $population.elems ) is export

Roulette wheel selection. 

=head2 mutation( @chromosome )

Returns the chromosome with a random bit flipped

=head2 crossover ( @chromosome1 is copy, @chromosome2 is copy )

Returns two cromosomes, with parts of it crossed over

=head2 produce-offspring( @pool,
		          $size = @pool.elems ) is export

Produces offspring from a pool array

=head2 best-fitness( $population )

Returns the fitness of the first element.

=head2 generation(  :@population,
		    :%fitness-of,
		    :$evaluator --> Bag )

Single generation of an evolutionary algorithm. The initial Bag
has to be evaluated before entering here using the C<evaluate> function.

=head2 mix( $population1, $population2, $size ) is export 
   
Mixes the two populations, returning a single one of the indicated size
				     
=head1 SEE ALSO

There is a very interesting implementation of an evolutionary algorithm in L<Algorithm::Genetic>. Check it out. This is also a port of L<Algorithm::Evolutionary::Simple in Perl6|https://metacpan.org/release/Algorithm-Evolutionary-Simple>, which has a few more goodies. 

=head1 AUTHOR

JJ Merelo <jjmerelo@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2018 JJ Merelo

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
