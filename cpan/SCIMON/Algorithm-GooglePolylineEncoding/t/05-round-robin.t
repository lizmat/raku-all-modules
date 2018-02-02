use v6.c;
use Test;
use Algorithm::GooglePolylineEncoding;

plan :skip-all<Skipping round robin test> if %*ENV<SKIP_ROUND_ROBIN>:exists;
plan 25920;
for (-90, * + 5 ... 85 ) -> $lat1 { 
    for ( -180, * + 5 ... 175 ) -> $lon1 {
        for ( 0.01, * + 0.01 ... 0.1 ) -> $d1 {
            my $d2 = $d1 / 10;
            my $lat2 = $lat1 + $d1;
            my $lat3 = $lat2 + $d2;
            my $lon2 = $lon1 + $d1;
            my $lon3 = $lon2 + $d2;
            is decode-polyline( encode-polyline( $lat1, $lon1, $lat2, $lon2, $lat3, $lon3 ) ),
            [ { :lat($lat1), :lon($lon1) }, {:lat($lat2), :lon($lon2) }, {:lat($lat3), :lon($lon3) } ],
            "$lat1, $lon1, $lat2, $lon2, $lat3, $lon3 OK";
        }
    }
}


