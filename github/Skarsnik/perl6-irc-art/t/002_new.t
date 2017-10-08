# -*- perl -*-

use Test;
plan 1;

use IRC::Art;

my $art = IRC::Art.new(5,5);

is $art.result.join('') ,(" " x 5," " x 5," " x 5," " x 5," " x 5).join(''), "Spaaace";


