# -*- perl -*-

use Test;
use IRC::Art;

plan 7;

my $art = IRC::Art.new(5,5);

$art.pixel(0,0,:color(5));
is-deeply([$art.result],[("\x[3]5,5 \x03    "," " x 5," " x 5," " x 5," " x 5)]);

$art.pixel(0,0,:color(5));
is-deeply([$art.result],[("\x[3]5,5 \x03    "," " x 5," " x 5," " x 5," " x 5)]);

$art.pixel(0,0,:color(5), :clear);
is-deeply([$art.result],[(" " x 5," " x 5," " x 5 ," " x 5," " x 5)]);

$art.pixel([0,1,2],[0,1,2],:color(5));
is-deeply([$art.result],[("\x[3]5,5 \x03    "," \x[3]5,5 \x[3]"~" "x 3,"  \x[3]5,5 \x03  "," "x 5," "x 5)]);

$art.pixel([0,1,2],[0,1,2],:color(5), :clear);
is-deeply([$art.result],[(" "x 5," "x 5," "x 5," " x 5," " x 5)]);

$art.pixel(0,0, :color(5));
$art.pixel(1,1, :color(5));
$art.pixel(2,2, :color(5));
is-deeply([$art.result],[("\x[3]5,5 \x03    "," \x[3]5,5 \x03"~" " x 3,"  \x[3]5,5 \x03  "," "x 5," "x 5)]);

$art.pixel(0,0, :clear);
$art.pixel(1,1, :clear);
$art.pixel(2,2, :clear);
is-deeply([$art.result],[(" "x 5," "x 5," "x 5," "x 5," "x 5)]);
