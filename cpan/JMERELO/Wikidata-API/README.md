# Wikidata API in Perl 6

[![Build Status](https://travis-ci.org/JJ/p6-wikidata-API.svg?branch=master)](https://travis-ci.org/JJ/p6-wikidata-API)

Perl6 module to query the wikidata API. Install it the usual way

    zef install Wikidata::API

Use it:

~~~
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
~~~
  
