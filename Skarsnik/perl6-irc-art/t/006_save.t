# -*- perl -*-

use Test;
use IRC::Art;
plan 1;
my $art = IRC::Art.new(5, 5);

$art.rectangle(0, 0, 4, 4, :color(5));
$art.save("t_test.aia");

my $art2 = IRC::Art.new;
$art2.load("t_test.aia");

is-deeply([$art2.result], [$art.result]);
unlink "t_test.aia";