# -*- perl -*-

use Test;
use IRC::Art;

plan 4;

my $art = IRC::Art.new(5,5);

$art.rectangle(0,0,4,4,:color(5));
is-deeply([$art.result],[("\x[3]5,5 \x[3]" x 5,"\x[3]5,5 \x[3]" x 5,"\x[3]5,5 \x03" x 5,"\x[3]5,5 \x03" x 5,"\x[3]5,5 \x03" x 5)]);

$art.rectangle(0,0,4,4, :color(5), :clear);
is-deeply([$art.result],[(" " x 5," " x 5," " x 5," " x 5," " x 5)]);

$art.rectangle(0,0,2,2,:color(5));
$art.rectangle(0,0,4,4,:color(5));
is-deeply([$art.result],[("\x[3]5,5 \x03" x 5,"\x[3]5,5 \x03" x 5,"\x[3]5,5 \x03" x 5,"\x[3]5,5 \x03" x 5,"\x[3]5,5 \x03" x 5)]);

$art.rectangle(0,0,4,4,:color(5),:clear);
is-deeply([$art.result],[(" " x 5," " x 5," " x 5," " x 5," " x 5)]);

