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
  
There are a few SPARQL queries you can
try [in this other repo](https://github.com/JJ/wikidata-queries) 

Download one query from that repo to test the command-line utility
that will be installed too

	wdq.p6 one-query-or-other.sparql

## See also

This module is tested using
the [`test-perl6`](https://hub.docker.com/r/jjmerelo/test-perl6/)
Docker container. Check out
the [Travis configuration file](.travis.yml) for usage.
