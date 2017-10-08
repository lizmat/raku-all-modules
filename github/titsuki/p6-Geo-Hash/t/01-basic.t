use v6.c;
use Test;
use Geo::Hash;
use Geo::Hash::Coord;

my $hash = geo-encode(42.60498046875e0, -5.60302734375e0, 5);
is $hash, "ezs42";
my Geo::Hash::Coord $coord = geo-decode($hash);
is $coord.latitude, 42.60498046875e0;
is geo-neighbors($hash), ("ezs48", "ezs49", "ezs43", "ezs41", "ezs40", "ezefp", "ezefr", "ezefx");

done-testing;
