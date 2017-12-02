use v6;

unit class Wikidata::API;
use URI::Encode;
use HTTP::Client;
use JSON::Tiny;

sub query (Str $query) is export {
    my $encoded = uri_encode $query;
    my $client = HTTP::Client.new;
    my $response = $client.get("https://query.wikidata.org/sparql?format=JSON\&query=" ~ $encoded );
    return from-json $response.content;
}

sub query-file (Str $query-file) is export {
    my $query = slurp $query-file;
    return query( $query );
}

=begin pod

=head1 NAME

Wikidata::API - Query the Wikidata API 

=head1 SYNOPSIS

  use Wikidata::API;

  my $query = q:to/END/;
SELECT ?person ?personLabel WHERE {
  
    ?person wdt:P69 wd:Q1232180 . 
    ?person wdt:P21 wd:Q6581072 . 
  
    SERVICE wikibase:label { 
      bd:serviceParam wikibase:language "en" .
    }
} ORDER BY ?personLabel
END

  my $UGR-women = query( $query );

  my $to-file= q:to/END/;
SELECT ?person ?personLabel ?occupation ?occupationLabel WHERE {
  ?person wdt:P69 wd:Q1232180. 
  ?person wdt:P21 wd:Q6581072.
  ?person wdt:P106 ?occupation
  SERVICE wikibase:label {				
    bd:serviceParam wikibase:language "es" .
  }
}
END

  spurt "ugr-women-by-job.sparql", $to-file;
  say query-file( $to-file );

=head1 DESCRIPTION

This is a convenience wrapper for the SPARQL endpoints of Wikidata, found at L<https://query.wikidata.org/>. You can either query directly using SPARQL (check out examples here: L<https://www.mediawiki.org/wiki/Special:MyLanguage/Wikidata_query_service>) or crafting a file and sending it. 

=over 4

=item query( Str $query)

Passes to the Wikidata API the SPARQL query, returns a data structure which includes L<results> with the rests of results

=item query-file( Str $query)

Opens the file and passes it to C<query> to make the request.
						     
=cut
									  
									  
=head1 AUTHOR

JJ Merelo <jjmerelo@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2017 JJ Merelo

This library is free software; you can redistribute it and/or modify it under the GPL 3.0.

=end pod
