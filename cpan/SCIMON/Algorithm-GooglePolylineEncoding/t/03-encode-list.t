use v6.c;
use Test;
use Algorithm::GooglePolylineEncoding;

my $encoded = q[_p~iF~ps|U_ulLnnqC_mqNvxq`@];

is encode-polyline( ( { :lat(38.5), :lon(-120.2) }, { :lat(40.7), :lon(-120.95) }, { :lat(43.252), :lon(-126.453) } ) ), $encoded, "list of hashes $encoded OK";
is encode-polyline( [ { :lat(38.5), :lon(-120.2) }, { :lat(40.7), :lon(-120.95) }, { :lat(43.252), :lon(-126.453) } ] ), $encoded, "array of hashes $encoded OK";
is encode-polyline( { :lat(38.5), :lon(-120.2) }, { :lat(40.7), :lon(-120.95) }, { :lat(43.252), :lon(-126.453) } ), $encoded, "hashes as args $encoded OK";
is encode-polyline( 38.5, -120.2, 40.7, -120.95, 43.252, -126.453 ), $encoded, "list of reals $encoded OK";

done-testing;
