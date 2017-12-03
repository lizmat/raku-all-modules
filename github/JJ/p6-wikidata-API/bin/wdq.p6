#!/usr/bin/env perl6

use Wikidata::API;
use JSON::Tiny;

sub MAIN( Str $sparql-file!) {
    say to-json query-file( $sparql-file );
    
}
