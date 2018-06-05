#!/usr/bin/env perl6

use lib 'lib';

use Bench;
use GeoIP2;

my $geo = GeoIP2.new( path => './t/databases/GeoIP2-City-Test.mmdb' );

Bench.new.timethese(
    1000,
    {
        'IPv4' => sub { my %result := $geo.locate( ip => '81.2.69.160' ) }
    }
);
