use v6.c;
use Test;
use Algorithm::GooglePolylineEncoding;

my $encoded = q[_p~iF~ps|U_ulLnnqC_mqNvxq`@];

is decode-polyline( $encoded ), [ { :lat(38.5), :lon(-120.2) }, { :lat(40.7), :lon(-120.95) }, { :lat(43.252), :lon(-126.453) } ], "String decoded OK";

done-testing;
