#!/usr/bin/env perl6

use v6;

use Algorithm::Evolutionary::Simple;

my $length = 32;
my $supplier = Supplier.new;
my $supply   = $supplier.Supply;
my $pairs = $supply.batch( elems => 2 );

$supply.tap( -> $v { say "First : ", $v });
$supply.tap( -> $χ { say max-ones( $χ ) } );
$pairs.tap( -> @pair { say crossover( @pair[0], @pair[1] )} );

for 1 .. 10 {
    $supplier.emit( random-chromosome($length) );
}


