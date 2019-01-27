#!/usr/bin/env perl6

use lib 'lib';

use Bench;
use GeoIP2;

multi sub MAIN ( :$database = './t/databases/GeoIP2-City-Test.mmdb', :$iterations = 1_000, :$file ) {

    my $geo = GeoIP2.new( path => $database );

    my $next;
    if defined $file {
        my $in = $file.IO.open( );
        $next = sub { return $in.get( ) }
    }
    else {
        $next = sub { return '81.2.69.160' }
    }

    Bench.new.timethese(
        $iterations,
        {
            'locate' => sub { $geo.locate( ip => $next( ) ) }
        }
    );
}
